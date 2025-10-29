import SwiftUI

/// The main view for the Solar System tab: renders orbits and planets with controls and info panel
struct SolarSystemView: View {
    @EnvironmentObject var store: AppStore
    
    var body: some View {
        ZStack {
            // Background fill (space black)
            Color.spaceBlack.ignoresSafeArea()
            
            // Solar system rendering canvas (orbits, planets, comet path)
            SolarCanvas()
                .environmentObject(store)
            
            // Bottom control panel: timeline slider + toggles, in a terminal-style panel
            VStack {
                Spacer()  // push controls to bottom
                TerminalPanel(borderColor: .terminalCyan) {
                    VStack(alignment: .leading, spacing: CGFloat.spaceSM) {
                        // Timeline slider (time 0-1)
                        NeonSlider(
                            value: Binding(
                                get: { store.state.time },
                                set: { newVal in store.dispatch(.setTime(newVal)) }
                            )
                        )
                        
                        // Toggle switches for ATLAS Path, Orbits, Labels
                        HStack(spacing: CGFloat.spaceLG) {
                            ToggleRow(title: NSLocalizedString("ATLAS Path", comment: "Toggle ATLAS path"), 
                                      isOn: Binding(
                                          get: { store.state.showAtlasPath },
                                          set: { store.dispatch(.toggleAtlas($0)) }
                                      ),
                                      accent: .terminalGreen)
                            ToggleRow(title: NSLocalizedString("Orbits", comment: "Toggle orbits"), 
                                      isOn: Binding(
                                          get: { store.state.showOrbits },
                                          set: { store.dispatch(.toggleOrbits($0)) }
                                      ),
                                      accent: .terminalGreen)
                            ToggleRow(title: NSLocalizedString("Labels", comment: "Toggle labels"), 
                                      isOn: Binding(
                                          get: { store.state.showLabels },
                                          set: { store.dispatch(.toggleLabels($0)) }
                                      ),
                                      accent: .terminalGreen)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
            
            // Info sheet overlay (appears when a celestial body is selected)
            if let selectedID = store.state.selected,
               let selectedBody = solarSystemBodies.first(where: { $0.id == selectedID }) {
                // Show the BodyInfoSheet as an overlay panel
                BodyInfoSheet(body: selectedBody)
                    .environmentObject(store)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 60)  // add bottom padding to sit above controls
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut(duration: 0.3), value: store.state.selected)
            }
        }
    }
}
