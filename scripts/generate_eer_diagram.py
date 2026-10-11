"""
SmartFlow Grid: Academic EER Diagram Generator (Chen Notation)
Generates an EER Diagram strictly matching the visual design, green geometry,
attribute ellipses, and relationship diamonds demonstrated in 'EER example.png'.
Outputs high-resolution PNG (300 DPI) and scalable vector SVG.
"""

import os
import matplotlib.pyplot as plt
import matplotlib.patches as patches

def draw_eer_diagram():
    os.makedirs("d:/Projects/DBMS Case Study/docs/figures", exist_ok=True)
    
    # 20x13 canvas with generous margins to avoid any clipping
    fig, ax = plt.subplots(figsize=(20, 13), dpi=300)
    ax.set_xlim(0, 110)
    ax.set_ylim(0, 85)
    ax.axis("off")
    fig.patch.set_facecolor("white")
    ax.set_facecolor("white")

    # Precise colors and line widths matching EER example.png
    COLOR_ENTITY_BORDER = "#23783c"   # Academic emerald green
    COLOR_REL_BORDER = "#23783c"      # Academic emerald green
    COLOR_ATTR_BORDER = "#1a1a1a"     # Dark charcoal/black
    COLOR_LINE = "#222222"            # Crisp connector lines
    COLOR_FILL = "#ffffff"            # Pure white fill
    
    # Helper functions
    def draw_entity(x, y, w, h, text):
        rect = patches.Rectangle(
            (x - w/2, y - h/2), w, h,
            linewidth=2.4, edgecolor=COLOR_ENTITY_BORDER, facecolor=COLOR_FILL,
            zorder=3
        )
        ax.add_patch(rect)
        ax.text(x, y, text, ha="center", va="center", fontsize=11.5, fontweight="bold",
                color="#000000", zorder=4)

    def draw_relationship(x, y, size_x, size_y, text):
        pts = [
            [x, y + size_y],
            [x + size_x, y],
            [x, y - size_y],
            [x - size_x, y]
        ]
        poly = patches.Polygon(
            pts, closed=True, linewidth=2.0, edgecolor=COLOR_REL_BORDER,
            facecolor=COLOR_FILL, zorder=3
        )
        ax.add_patch(poly)
        ax.text(x, y, text, ha="center", va="center", fontsize=10, fontweight="semibold",
                color="#000000", zorder=4)

    def draw_attribute(x, y, rx, ry, text, is_pk=False):
        ellipse = patches.Ellipse(
            (x, y), rx * 2, ry * 2,
            linewidth=1.3, edgecolor=COLOR_ATTR_BORDER, facecolor=COLOR_FILL,
            zorder=3
        )
        ax.add_patch(ellipse)
        weight = "bold" if is_pk else "normal"
        ax.text(x, y + (0.2 if is_pk else 0), text, ha="center", va="center", fontsize=9.0,
                fontweight=weight, color="#000000", zorder=4)
        if is_pk:
            # Underline primary key (Chen standard)
            half_w = min(rx * 0.72, len(text) * 0.35)
            ax.plot([x - half_w, x + half_w], [y - 0.75, y - 0.75],
                    color="#000000", linewidth=1.3, zorder=4)

    def draw_line(p1, p2):
        ax.plot([p1[0], p2[0]], [p1[1], p2[1]], color=COLOR_LINE, linewidth=1.2, zorder=2)

    # -------------------------------------------------------------------------
    # Spatial Entity Layout
    # -------------------------------------------------------------------------
    # Top Row Entities
    E_INTERSECT = (20, 60)
    E_LANE = (55, 60)
    E_PHASE = (90, 60)

    # Bottom Row Entities
    E_SENSOR = (42, 22)
    E_AUDIT = (88, 22)

    # Relationship Diamonds
    R_HAS_LANE = (37.5, 60)
    R_GOVERNS = (72.5, 60)
    R_RECORDS = (48.5, 41)
    R_AUDITS = (89, 41)

    # -------------------------------------------------------------------------
    # Connect Entities to Relationships + Cardinalities
    # -------------------------------------------------------------------------
    # Intersection <(1)--- has ---(N)> Lane
    draw_line(E_INTERSECT, R_HAS_LANE)
    ax.text(30.5, 61.5, "1", fontsize=11, fontweight="bold")
    draw_line(R_HAS_LANE, E_LANE)
    ax.text(44.5, 61.5, "N", fontsize=11, fontweight="bold")

    # Lane <(1)--- governed_by ---(1)> Signal_Phase
    draw_line(E_LANE, R_GOVERNS)
    ax.text(64.5, 61.5, "1", fontsize=11, fontweight="bold")
    draw_line(R_GOVERNS, E_PHASE)
    ax.text(80.5, 61.5, "1", fontsize=11, fontweight="bold")

    # Lane <(1)--- records ---(N)> Sensor_Log
    draw_line(E_LANE, R_RECORDS)
    ax.text(53.5, 52, "1", fontsize=11, fontweight="bold")
    draw_line(R_RECORDS, E_SENSOR)
    ax.text(43.5, 30.5, "N", fontsize=11, fontweight="bold")

    # Signal_Phase <(1)--- triggers ---(N)> Audit_Traffic_Log
    draw_line(E_PHASE, R_AUDITS)
    ax.text(91, 52, "1", fontsize=11, fontweight="bold")
    draw_line(R_AUDITS, E_AUDIT)
    ax.text(90, 30.5, "N", fontsize=11, fontweight="bold")

    # -------------------------------------------------------------------------
    # Draw Relationship Diamonds
    # -------------------------------------------------------------------------
    draw_relationship(R_HAS_LANE[0], R_HAS_LANE[1], 4.2, 3.2, "has")
    draw_relationship(R_GOVERNS[0], R_GOVERNS[1], 5.2, 3.2, "governed_by")
    draw_relationship(R_RECORDS[0], R_RECORDS[1], 4.8, 3.2, "records")
    draw_relationship(R_AUDITS[0], R_AUDITS[1], 4.8, 3.2, "triggers")

    # -------------------------------------------------------------------------
    # Draw Entity Rectangles
    # -------------------------------------------------------------------------
    draw_entity(E_INTERSECT[0], E_INTERSECT[1], 15, 5.5, "Intersection")
    draw_entity(E_LANE[0], E_LANE[1], 13, 5.5, "Lane")
    draw_entity(E_PHASE[0], E_PHASE[1], 15, 5.5, "Signal_Phase")
    draw_entity(E_SENSOR[0], E_SENSOR[1], 15, 5.5, "Sensor_Log")
    draw_entity(E_AUDIT[0], E_AUDIT[1], 17, 5.5, "Audit_Traffic_Log")

    # -------------------------------------------------------------------------
    # Entity 1: Intersection Attributes
    # -------------------------------------------------------------------------
    attrs_intersect = [
        (8, 72, 6.2, 2.3, "Intersection_id", True),
        (20, 75, 6.0, 2.3, "Location_name", False),
        (31, 72, 5.5, 2.3, "Grid_zone", False),
    ]
    for ax_pos, ay_pos, rx, ry, name, is_pk in attrs_intersect:
        draw_line(E_INTERSECT, (ax_pos, ay_pos))
        draw_attribute(ax_pos, ay_pos, rx, ry, name, is_pk)

    # -------------------------------------------------------------------------
    # Entity 2: Lane Attributes
    # -------------------------------------------------------------------------
    attrs_lane = [
        (45, 73, 5.2, 2.3, "Lane_id", True),
        (55, 76, 5.4, 2.3, "Direction", False),
        (65, 73, 5.8, 2.3, "Capacity_limit", False),
        (63, 49, 7.5, 2.3, "Is_emergency_corridor", False),
    ]
    for ax_pos, ay_pos, rx, ry, name, is_pk in attrs_lane:
        draw_line(E_LANE, (ax_pos, ay_pos))
        draw_attribute(ax_pos, ay_pos, rx, ry, name, is_pk)

    # -------------------------------------------------------------------------
    # Entity 3: Signal_Phase Attributes
    # -------------------------------------------------------------------------
    attrs_phase = [
        (78, 73, 5.2, 2.3, "Phase_id", True),
        (89, 76, 5.8, 2.3, "Current_state", False),
        (100, 73, 6.5, 2.3, "Duration_seconds", False),
        (106, 60, 5.8, 2.3, "Last_updated", False),
    ]
    for ax_pos, ay_pos, rx, ry, name, is_pk in attrs_phase:
        draw_line(E_PHASE, (ax_pos, ay_pos))
        draw_attribute(ax_pos, ay_pos, rx, ry, name, is_pk)

    # -------------------------------------------------------------------------
    # Entity 4: Sensor_Log Attributes
    # -------------------------------------------------------------------------
    attrs_sensor = [
        (24, 22, 5.2, 2.3, "Log_id", True),
        (33, 9, 5.2, 2.3, "Car_count", False),
        (48, 9, 5.6, 2.3, "Recorded_at", False),
    ]
    for ax_pos, ay_pos, rx, ry, name, is_pk in attrs_sensor:
        draw_line(E_SENSOR, (ax_pos, ay_pos))
        draw_attribute(ax_pos, ay_pos, rx, ry, name, is_pk)

    # -------------------------------------------------------------------------
    # Entity 5: Audit_Traffic_Log Attributes
    # -------------------------------------------------------------------------
    attrs_audit = [
        (72, 9, 5.2, 2.3, "Audit_id", True),
        (83, 7, 5.2, 2.3, "Old_state", False),
        (94, 7, 5.2, 2.3, "New_state", False),
        (103, 16, 5.4, 2.3, "Changed_at", False),
        (103, 28, 5.8, 2.3, "Trigger_source", False),
    ]
    for ax_pos, ay_pos, rx, ry, name, is_pk in attrs_audit:
        draw_line(E_AUDIT, (ax_pos, ay_pos))
        draw_attribute(ax_pos, ay_pos, rx, ry, name, is_pk)

    # Title Banner
    ax.text(55, 3.5, "SmartFlow Grid: Extended Entity-Relationship (EER) Model",
            ha="center", va="center", fontsize=15, fontweight="bold", color="#1b5e20")

    png_path = "d:/Projects/DBMS Case Study/docs/figures/SmartFlow_Grid_EER_Diagram.png"
    svg_path = "d:/Projects/DBMS Case Study/docs/figures/SmartFlow_Grid_EER_Diagram.svg"
    root_png = "d:/Projects/DBMS Case Study/docs/SmartFlow_Grid_EER_Diagram.png"

    plt.savefig(png_path, format="png", dpi=300, bbox_inches="tight", facecolor="white")
    plt.savefig(svg_path, format="svg", bbox_inches="tight", facecolor="white")
    plt.savefig(root_png, format="png", dpi=300, bbox_inches="tight", facecolor="white")
    plt.close()

    print("[OK] Enhanced EER diagram regenerated.")

if __name__ == "__main__":
    draw_eer_diagram()
