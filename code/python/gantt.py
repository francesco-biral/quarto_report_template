"""Gantt charts from a CSV work plan, styled with the report brand.

CSV columns (header required):

    wp,task,start,end,type
    WP1 Modelling,Literature review,2026-01,2026-02,done
    WP1 Modelling,Model development,2026-02,2026-05,
    WP3 Dissemination,Interim report (D3.1),2026-06,,milestone

- wp     work package / group (rows keep the CSV order)
- task   task label
- start  YYYY-MM (start of month) or YYYY-MM-DD
- end    YYYY-MM (end of month) or YYYY-MM-DD; empty for milestones
- type   empty | done | milestone

Usage in a Quarto cell:

    import sys; sys.path.insert(0, "code/python")
    from gantt import gantt
    gantt("data/workplan.csv", today="2026-11-17")

Options: scale="month" | "quarter" | "project" (M1, M2, ...),
highlight="WP2 ..." (fade other work packages), today=None,
width (inches, default = text width), project_start (for scale="project").
"""

from __future__ import annotations

import calendar
import csv
import glob
from datetime import date, datetime, timedelta
from pathlib import Path

import matplotlib.dates as mdates
import matplotlib.pyplot as plt
from matplotlib import colors as mcolors
from matplotlib import font_manager

try:
    from brand import brand
except ImportError:  # pragma: no cover
    def brand(root="."):
        return {"primary": "#004d80", "accent": "#d07a02", "ink": "#1b2530",
                "muted": "#647381", "line": "#d9e2e8"}

# Register bundled Montserrat so the chart matches the report headings.
for _f in glob.glob(str(Path("assets/fonts") / "Montserrat-*.ttf")):
    try:
        font_manager.fontManager.addfont(_f)
    except Exception:
        pass


# ---------------------------------------------------------------- dates -----
def _parse(value: str, end: bool = False) -> date | None:
    value = (value or "").strip()
    if not value:
        return None
    if len(value) == 7:  # YYYY-MM
        y, m = map(int, value.split("-"))
        return date(y, m, calendar.monthrange(y, m)[1]) if end else date(y, m, 1)
    return datetime.strptime(value, "%Y-%m-%d").date()


def _month_start(d: date) -> date:
    return date(d.year, d.month, 1)


def _add_months(d: date, n: int) -> date:
    y, m = divmod(d.month - 1 + n, 12)
    return date(d.year + y, m + 1, 1)


def _months_between(a: date, b: date) -> int:
    return (b.year - a.year) * 12 + b.month - a.month


# ---------------------------------------------------------------- chart -----
def gantt(
    csv_path: str,
    *,
    scale: str = "month",
    today: str | None = None,
    highlight: str | None = None,
    project_start: str | None = None,
    width: float = 6.3,
    row_height: float = 0.26,
):
    b = brand()
    with open(csv_path, newline="", encoding="utf-8") as fh:
        rows = [
            {k: (v or "").strip() for k, v in r.items()}
            for r in csv.DictReader(fh)
            if any((v or "").strip() for v in r.values())
        ]
    for r in rows:
        r["type"] = r.get("type", "").lower()
        r["s"] = _parse(r["start"])
        r["e"] = _parse(r.get("end", ""), end=True)
        if r["type"] == "milestone":
            # Month-only milestone = due at the end of that month.
            r["s"] = _parse(r["start"], end=len(r["start"]) == 7)
            r["e"] = r["s"]
        elif r["e"] is None:
            raise ValueError(f"Task '{r['task']}' needs an end date (or type=milestone).")

    wps = list(dict.fromkeys(r["wp"] for r in rows))
    # One shade per work package, from primary to a light tint of it.
    light = mcolors.to_hex([(c + 2) / 3 for c in mcolors.to_rgb(b["primary"])])
    cmap = mcolors.LinearSegmentedColormap.from_list("wp", [b["primary"], light])
    wp_color = {wp: mcolors.to_hex(cmap(i / max(1, len(wps) - 1) * 0.75)) for i, wp in enumerate(wps)}

    # Layout: a header row per work package, then its tasks.
    layout = []
    for wp in wps:
        tasks = [r for r in rows if r["wp"] == wp]
        layout.append(("wp", wp, tasks))
        layout += [("task", wp, r) for r in tasks]

    t0 = _month_start(min(r["s"] for r in rows))
    if scale == "quarter":  # align to the start of a quarter
        t0 = date(t0.year, (t0.month - 1) // 3 * 3 + 1, 1)
    t1 = _add_months(_month_start(max(r["e"] for r in rows)), 1)
    if scale == "quarter":
        while _months_between(t0, t1) % 3:
            t1 = _add_months(t1, 1)
    p0 = _month_start(_parse(project_start)) if project_start else t0

    plt.rcParams.update({"font.family": ["Montserrat", "DejaVu Sans"], "font.size": 7.5})
    n = len(layout)
    fig, ax = plt.subplots(figsize=(width, row_height * n + 0.75), constrained_layout=True)

    def faded(wp):
        return highlight is not None and wp != highlight

    for y, (kind, wp, item) in enumerate(layout):
        alpha_wp = 0.25 if faded(wp) else 1.0
        if kind == "wp":
            s = min(r["s"] for r in item)
            e = max(r["e"] for r in item) + timedelta(days=1)
            ax.barh(y, e - s, left=s, height=0.16, color=wp_color[wp], alpha=alpha_wp)
            continue
        r = item
        if r["type"] == "milestone":
            ax.plot(r["s"], y, marker="D", ms=6.5, color=b["accent"],
                    alpha=alpha_wp, zorder=3, clip_on=False)
        else:
            e = r["e"] + timedelta(days=1)
            alpha = (0.4 if r["type"] == "done" else 1.0) * alpha_wp
            ax.barh(y, e - r["s"], left=r["s"], height=0.58, color=wp_color[wp],
                    alpha=alpha, edgecolor="none")

    # Y labels
    ax.set_yticks(range(n))
    ax.set_yticklabels([wp if kind == "wp" else item["task"] for kind, wp, item in layout])
    for lab, (kind, wp, _) in zip(ax.get_yticklabels(), layout):
        lab.set_fontweight("semibold" if kind == "wp" else "normal")
        lab.set_color(b["ink"] if kind == "wp" else b["muted"])
        if faded(wp):
            lab.set_alpha(0.45)
    ax.set_ylim(n - 0.4, -0.6)

    # X axis: month cells with centred labels, grid on the boundaries.
    ax.set_xlim(t0, t1)
    months = _months_between(t0, t1)
    step = {"month": 1, "project": 1, "quarter": 3}.get(scale, 1)
    if months > 24 and scale != "quarter":
        step = 2
    bounds = [_add_months(t0, i) for i in range(0, months + 1)]
    ax.set_xticks(bounds, minor=False)
    ax.set_xticklabels([])
    for i, bnd in enumerate(bounds):
        if scale == "quarter" and i % 3:
            continue
        major = bnd.month == 1 if scale != "project" else (_months_between(p0, bnd) % 12 == 0)
        ax.axvline(bnd, color=b["line"], lw=0.9 if major else 0.5, zorder=0)

    centres, labels = [], []
    for i in range(0, months, step):
        a = _add_months(t0, i)
        z = _add_months(t0, min(i + step, months))
        centres.append(a + (z - a) / 2)
        if scale == "quarter":
            q = (a.month - 1) // 3 + 1
            labels.append(f"Q{q}\n{a.year}" if (i == 0 or q == 1) else f"Q{q}")
        elif scale == "project":
            labels.append(f"M{_months_between(p0, a) + 1}")
        else:
            first = i == 0 or a.month == 1
            labels.append(a.strftime("%b") + (f"\n{a.year}" if first else ""))
    ax.set_xticks(centres, labels, minor=True)
    ax.xaxis.tick_top()
    ax.tick_params(axis="x", which="both", length=0, colors=b["muted"], pad=3)
    ax.tick_params(axis="y", length=0, pad=6)
    for side in ax.spines.values():
        side.set_visible(False)

    if today:
        td = _parse(today)
        if t0 <= td <= t1:
            ax.axvline(td, color=b["accent"], lw=1, ls=(0, (3, 2)), zorder=4)
            ax.annotate("today", (mdates.date2num(td), n - 0.4), xytext=(2, 2),
                        textcoords="offset points", color=b["accent"], fontsize=6.5,
                        ha="left", va="bottom")
    return fig
