import matplotlib.pyplot as plt
import matplotlib.patches as patches
from pathlib import Path

def create_logical_diagram():
    # Canvas setup matching reference image aspect ratio and clean white background
    fig, ax = plt.subplots(figsize=(13.5, 9), dpi=300)
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 100)
    ax.axis('off')
    fig.patch.set_facecolor('#ffffff')

    # Color palette strictly matching reference image:
    # Reference green tables: Patient, Cortical_element, EEG_grid, Electrode, SPI
    GREEN_BORDER = '#254a23'
    GREEN_HEADER = '#cbeec8'
    GREEN_BODY = '#dcf6d9'
    
    # Reference orange table: Cluster (central entity)
    ORANGE_BORDER = '#8c4815'
    ORANGE_HEADER = '#f8c89a'
    ORANGE_BODY = '#fde2c9'
    
    LINE_COLOR = '#1a1a1a'
    TEXT_COLOR = '#111111'

    def draw_entity(x, y, w, header_h, body_h, title, pks, fks, attrs, is_orange=False):
        """
        Draws an entity box with title above, shaded header compartment with bold keys,
        and body compartment with non-key attributes.
        """
        border_col = ORANGE_BORDER if is_orange else GREEN_BORDER
        header_bg = ORANGE_HEADER if is_orange else GREEN_HEADER
        body_bg = ORANGE_BODY if is_orange else GREEN_BODY

        # Entity Title above the box (Bold, centered)
        ax.text(x + w / 2, y + header_h + body_h + 2.0, title,
                ha='center', va='bottom', fontsize=12.5, fontweight='bold',
                fontfamily='sans-serif', color=TEXT_COLOR)

        # Body rectangle (bottom compartment)
        body_rect = patches.Rectangle(
            (x, y), w, body_h,
            linewidth=1.4, edgecolor=border_col, facecolor=body_bg, zorder=2
        )
        ax.add_patch(body_rect)

        # Header rectangle (top compartment)
        header_rect = patches.Rectangle(
            (x, y + body_h), w, header_h,
            linewidth=1.4, edgecolor=border_col, facecolor=header_bg, zorder=2
        )
        ax.add_patch(header_rect)

        # Keys inside header (BOLD, mentioning PK and FK)
        all_keys = []
        for pk in pks:
            all_keys.append(f"{pk} (PK)")
        for fk in fks:
            all_keys.append(f"{fk} (FK)")

        key_spacing = header_h / (len(all_keys) + 1)
        for i, key_text in enumerate(all_keys):
            ky = y + body_h + header_h - (i + 1) * key_spacing
            ax.text(x + 1.2, ky, key_text,
                    ha='left', va='center', fontsize=9.8, fontweight='bold',
                    fontfamily='sans-serif', color=TEXT_COLOR, zorder=3)

        # Attributes inside body (Regular weight)
        attr_spacing = body_h / (len(attrs) + 1)
        for i, attr_text in enumerate(attrs):
            ay = y + body_h - (i + 1) * attr_spacing
            ax.text(x + 1.2, ay, attr_text,
                    ha='left', va='center', fontsize=9.5, fontweight='normal',
                    fontfamily='sans-serif', color=TEXT_COLOR, zorder=3)

    # 1. Intersection (Top-Left)
    inter_x, inter_y = 6, 66
    inter_w = 23
    inter_hh = 6.0
    inter_bh = 8.5
    draw_entity(
        inter_x, inter_y, inter_w, inter_hh, inter_bh,
        title="Intersection",
        pks=["Intersection_ID"],
        fks=[],
        attrs=["Location_Name", "Grid_Zone"]
    )

    # 2. Lane (Center - Orange highlight like Cluster in reference)
    lane_x, lane_y = 38, 43
    lane_w = 25
    lane_hh = 9.8
    lane_bh = 12.0
    draw_entity(
        lane_x, lane_y, lane_w, lane_hh, lane_bh,
        title="Lane",
        pks=["Lane_ID"],
        fks=["Intersection_ID"],
        attrs=["Direction", "Capacity_Limit", "Is_Emergency_Corridor"],
        is_orange=True
    )

    # 3. Signal_Phase (Top-Right)
    sig_x, sig_y = 71, 57
    sig_w = 24
    sig_hh = 13.5
    sig_bh = 12.0
    draw_entity(
        sig_x, sig_y, sig_w, sig_hh, sig_bh,
        title="Signal_Phase",
        pks=["Phase_ID"],
        fks=["Lane_ID", "Intersection_ID"],
        attrs=["Current_State", "Duration_Seconds", "Last_Updated"]
    )

    # 4. Sensor_Log (Bottom-Left)
    sens_x, sens_y = 7, 14
    sens_w = 23
    sens_hh = 9.8
    sens_bh = 8.5
    draw_entity(
        sens_x, sens_y, sens_w, sens_hh, sens_bh,
        title="Sensor_Log",
        pks=["Log_ID"],
        fks=["Lane_ID"],
        attrs=["Car_Count", "Recorded_At"]
    )

    # 5. Audit_Traffic_Log (Bottom-Right)
    audit_x, audit_y = 69, 12
    audit_w = 26
    audit_hh = 9.8
    audit_bh = 15.0
    draw_entity(
        audit_x, audit_y, audit_w, audit_hh, audit_bh,
        title="Audit_Traffic_Log",
        pks=["Audit_ID"],
        fks=["Phase_ID"],
        attrs=["Old_State", "New_State", "Changed_At", "Trigger_Source"]
    )

    # Clean Orthogonal Connector Paths (never crossing any title or label)
    def draw_path(points):
        xs, ys = zip(*points)
        ax.plot(xs, ys, color=LINE_COLOR, linewidth=1.4, zorder=1)

    # Path 1: Intersection -> Lane
    # From right edge of Intersection header to left edge of Lane header
    draw_path([
        (inter_x + inter_w, inter_y + inter_bh + inter_hh / 2),
        (33.5, inter_y + inter_bh + inter_hh / 2),
        (33.5, lane_y + lane_bh + lane_hh * 0.75),
        (lane_x, lane_y + lane_bh + lane_hh * 0.75)
    ])

    # Path 2: Intersection -> Signal_Phase
    # Starts at left edge of Intersection top (away from title), routes up and across to right side of Signal_Phase
    draw_path([
        (inter_x + 2.5, inter_y + inter_bh + inter_hh),
        (inter_x + 2.5, 93),
        (sig_x + sig_w - 2.5, 93),
        (sig_x + sig_w - 2.5, sig_y + sig_bh + sig_hh)
    ])

    # Path 3: Lane -> Signal_Phase
    # From right edge of Lane to left edge of Signal_Phase
    draw_path([
        (lane_x + lane_w, lane_y + lane_bh + lane_hh * 0.45),
        (67, lane_y + lane_bh + lane_hh * 0.45),
        (67, sig_y + sig_bh + sig_hh * 0.45),
        (sig_x, sig_y + sig_bh + sig_hh * 0.45)
    ])

    # Path 4: Lane -> Sensor_Log
    # Starts from bottom of Lane, routes to RIGHT edge of Sensor_Log (never crosses Sensor_Log title)
    draw_path([
        (lane_x + lane_w * 0.25, lane_y),
        (lane_x + lane_w * 0.25, 27),
        (sens_x + sens_w, 27)
    ])

    # Path 5: Signal_Phase -> Audit_Traffic_Log
    # Starts from bottom of Signal_Phase, routes to TOP-RIGHT of Audit_Traffic_Log (away from title)
    draw_path([
        (sig_x + sig_w * 0.75, sig_y),
        (sig_x + sig_w * 0.75, audit_y + audit_bh + audit_hh + 6),
        (audit_x + audit_w - 3.0, audit_y + audit_bh + audit_hh + 6),
        (audit_x + audit_w - 3.0, audit_y + audit_bh + audit_hh)
    ])

    # Save to outputs
    output_dir = Path("docs/figures")
    output_dir.mkdir(parents=True, exist_ok=True)
    
    png_path = output_dir / "logical_schema_diagram.png"
    svg_path = output_dir / "logical_schema_diagram.svg"

    plt.tight_layout()
    plt.savefig(png_path, dpi=300, bbox_inches='tight', facecolor=fig.get_facecolor(), edgecolor='none')
    plt.savefig(svg_path, format='svg', bbox_inches='tight', facecolor=fig.get_facecolor(), edgecolor='none')
    plt.close()
    print(f"Generated {png_path} and {svg_path}")

if __name__ == "__main__":
    create_logical_diagram()
