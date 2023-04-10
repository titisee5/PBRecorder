bool showInterface;

void RenderInterface() {
    if (!showInterface) return;
    UI::PushStyleVar(UI::StyleVar::WindowPadding, vec2(10, 10));
    UI::PushStyleVar(UI::StyleVar::FramePadding, vec2(10, 6));
    UI::PushStyleVar(UI::StyleVar::WindowTitleAlign, vec2(.5, .5));
    int flags = UI::WindowFlags::NoCollapse | UI::WindowFlags::AlwaysAutoResize | UI::WindowFlags::NoResize;
    if (UI::Begin("\\$6f9" + Icons::VideoCamera + " \\$zPB Recorder", showInterface, flags)){
        if (playground is null) {
            UI::Text("You must be playing a map to be able to record replays.");
        } else {
            if (inProgress) {
                UI::Text("\\$f00" + Icons::Circle + " \\$zRecording...");
                UI::Text(totalRecorded + " replays recorded.");
                UI::TextDisabled("Replays will be saved to " + save_path);
                if (UI::Button(Icons::StopCircle + " Stop recording")) {
                    inProgress = false;
                    totalRecorded = 0;
                }
                AddSimpleTooltip("Stop recording");
            } else {
                UI::Text(ColoredString(map.MapName));
                UI::TextDisabled(map.AuthorNickName);
                if (UI::Button(Icons::PlayCircle + " Start recording")) StartRecording(false);
                AddSimpleTooltip("Start recording");
            }
            UI::SameLine();
            if (in_maps) {
                if (UI::Button(Icons::MinusCircle)) RemoveMap();
                AddSimpleTooltip("Remove map from automatic recording list");
            } else {
                if (UI::Button(Icons::PlusCircle)) AddMap();
                AddSimpleTooltip("Add map to automatic recording list");
            }
        }
    }
    UI::End();
    UI::PopStyleVar(3);
}

void RenderMenu()
{
    if (
        UI::MenuItem(
            "\\$6f9" + Icons::VideoCamera + " \\$zPB Recorder",
            inProgress ? ("\\$f00" + Icons::Circle + " \\$z(" + totalRecorded + ")") : "",
            showInterface
        )
    )
    showInterface = !showInterface;
}

void RenderMenuMain(){
    if (inProgress && UI::MenuItem("\\$f00" + Icons::Circle + " \\$666(" + totalRecorded + ")" + " \\$zReplay Recording in progress")) {
        inProgress = false;
        totalRecorded = 0;
    }
    if (inProgress && UI::IsItemHovered()) {
        UI::BeginTooltip();
        UI::Text("\\$6f9" + Icons::VideoCamera + " \\$zClick to stop recording");
        UI::TextDisabled(Icons::InfoCircle + " Replays are saved to " + save_path);
        UI::EndTooltip();
    }
}

void AddSimpleTooltip(const string &in msg) {
    if (UI::IsItemHovered()) {
        UI::BeginTooltip();
        UI::Text(msg);
        UI::EndTooltip();
    }
}
