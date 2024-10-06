import Trix from "trix";

export default {
    mounted() {
        const element = document.querySelector("trix-editor");
        element.editor.element.addEventListener("trix-change", (e) => {
            this.el.dispatchEvent(new Event("change", { bubbles: true }));
        });
        element.editor.element.addEventListener("trix-initialize", () => {
            // element.editor.element.focus();
            var length = element.editor.getDocument().toString().length;
            window.setTimeout(() => {
                element.editor.setSelectedRange(length, length);
            }, 1);
        });
        element.editor.element.addEventListener("trix-attachment-add", (event) => {
            if (event.attachment.file) {
                let attachment = event.attachment;
                console.log(attachment);
                let upload = this.uploadTo(this.el, "images", [event.attachment.file]);
                console.log(upload);

                this.handleEvent("upload-progress", ({ progress: progress, name: name }) => {
                    attachment.setUploadProgress(progress);
                    // console.log("upload-progress", payload)
                });
                this.handleEvent("upload-completed", ({ name: name, url: url }) => {
                    attachment.setAttributes({
                        url: url,
                        href: url,
                    })
                });
            }
        });
        this.handleEvent("updateContent", (data) => {
            element.editor.loadHTML(data.content || "");
        });
    },
};
