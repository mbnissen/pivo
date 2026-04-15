const ShareHook = {
  mounted() {
    const url = this.el.dataset.url;
    const text = this.el.dataset.text;
    const title = this.el.dataset.title;

    const nativeBtn = this.el.querySelector("[data-share-native]");
    if (nativeBtn && navigator.share) {
      nativeBtn.classList.remove("hidden");
      nativeBtn.addEventListener("click", async () => {
        try {
          await navigator.share({ title, text, url });
        } catch (err) {
          if (err.name !== "AbortError") console.error(err);
        }
      });
    }

    const copyBtn = this.el.querySelector("[data-share-copy]");
    const copyLabel = this.el.querySelector("[data-copy-label]");
    if (copyBtn) {
      copyBtn.addEventListener("click", async () => {
        try {
          await navigator.clipboard.writeText(url);
          if (copyLabel) {
            const original = copyLabel.textContent;
            copyLabel.textContent = "Copied!";
            setTimeout(() => (copyLabel.textContent = original), 1500);
          }
        } catch (err) {
          console.error(err);
        }
      });
    }
  },
};

export default ShareHook;
