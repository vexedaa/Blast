local ReplicatedStorage = game:GetService("ReplicatedStorage")

return {
    bundles = {
        socket = {
            bundle_template = ReplicatedStorage.Assets.Bundles.Templates.socket_bundle_template;
            export_path = ReplicatedStorage.Assets.Bundles.Types.Sockets;
        };
        room = {
            bundle_template = ReplicatedStorage.Assets.Bundles.Templates.room_bundle_template;
            export_path = ReplicatedStorage.Assets.Bundles.Types.Rooms;
        };
    }
}