from gi.repository import Gio, GLib
from time import sleep

address = "unix:abstract=gstswitch"
name = None
object_path = "/info/duzy/gst_switch/SwitchController"
connection = Gio.DBusConnection.new_for_address_sync(
                    address,
                    Gio.DBusConnectionFlags.AUTHENTICATION_CLIENT,
                    None, None)
b =  connection.call_sync(
            name, object_path, 'info.duzy.gst_switch.SwitchControllerInterface', 'set_composite_mode',
            args, GLib.VariantType.new("(b)"), Gio.DBusCallFlags.NONE, -1,
            None)
mode = 1
args = GLib.Variant('(i)',(mode,))
print "args:", args
b =  connection.call_sync(
            name, object_path, 'info.duzy.gst_switch.SwitchControllerInterface', 'set_composite_mode',
            args, GLib.VariantType.new("(b)"), Gio.DBusCallFlags.NONE, -1,
            None)

print b