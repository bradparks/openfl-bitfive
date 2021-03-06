package flash.net;
#if js
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.Lib;
import flash.utils.ByteArray;
import js.html.AnchorElement;
import js.html.Blob;
import js.html.DivElement;
import js.html.File;
import js.html.FileReader;
import js.html.FormElement;
import js.html.InputElement;

class FileReference extends flash.events.EventDispatcher {
	private var fileInput:InputElement;
	private var fileForm:FormElement; // form wrapper (to be able to reset file selection)
	private var fileLink:AnchorElement;
	private var file:File;
	//
	public var data:ByteArray;
	public var name(get, null):String;
	public var size(get, null):Float;
	public var type(get, null):String;
	public var creationDate(get, null):Date;
	public var modificationDate(get, null):Date;
	//
	public function new() {
		super();
	}
	public function browse(?f:Array<FileFilter>):Bool {
		var h:DivElement = Lib.jsHelper(), o:InputElement, q:FormElement = fileForm,
			s:String, i:Int, l:Int, p:Int, fs:Array<String>, x:String;
		if (q == null) {
			fileInput = o = untyped document.createElement("input");
			fileForm = q = untyped document.createElement("form");
			fileForm.appendChild(o);
			o.type = "file";
			o.onchange = onFileChange;
		} else {
			o = fileInput;
			q.reset();
		}
		// form "accept" string:
		s = "";
		if (f != null) {
			// form "*.ext1;*.ext2;...":
			i = -1; l = f.length; while (++i < l) {
				if (s != "") s += ";";
				s += f[i].extension;
			}
			// convert to ".ext1,.ext2,...":
			fs = s.split(";");
			s = "";
			i = -1; l = fs.length; while (++i < l)
			if ((p = fs[i].lastIndexOf(".")) != -1) // should have a dot
			if ((x = fs[i].substr(p)) != "*") { // isn't *.* (which's auto-added by browser)
				if (s != "") s += ",";
				s += x;
			}
		}
		// node must be on page for IE to permit interactions:
		o.accept = s;
		h.appendChild(q);
		o.click();
		h.removeChild(q);
		return true;
	}
	public function save(d:ByteArray, ?n:String) {
		var q:AnchorElement = fileLink, h:DivElement = Lib.jsHelper();
		if (q == null) {
			fileLink = q = untyped document.createElement("a");
		}
		q.download = untyped n || ""; // shows "null"/"undefined" otherwise
		q.href = "data:application/octet-stream;base64," + d.toBase64();
		h.appendChild(q);
		q.click();
		h.removeChild(q);
	}
	public function load() {
		if (file != null) try {
			var r:FileReader = new FileReader();
			r.readAsArrayBuffer(file);
			data = null;
			dispatchEvent(new Event(Event.OPEN));
			r.onload = function(_) {
				data = ByteArray.nmeOfBuffer(r.result);
				dispatchEvent(new Event(Event.COMPLETE));
			}
			r.onerror = function(_) dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR,
				false, false, "Failed to load the file."));
		} catch (_:Dynamic) throw "Failed to dispatch FileReader.";
	}
	// events
	private function onFileChange(_):Void {
		file = fileInput.files[0];
		if (file != null) dispatchEvent(new Event(Event.SELECT));
		untyped window._file = file;
	}
	// properties
	private function get_name() return file.name;
	private function get_size() return file.size;
	private function get_type() {
		var t:String = file.type, p:Int = t.lastIndexOf(".");
		return p != -1 ? t.substr(p - 1) : null;
	}
	private function get_modificationDate() return file.lastModifiedDate;
	// not in standard, so not many options here:
	private function get_creationDate() return file.lastModifiedDate;
}
#end