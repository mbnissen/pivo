const ShareHook = {
  mounted() {
    const url = this.el.dataset.url;
    const text = this.el.dataset.text;
    const title = this.el.dataset.title;

    const nativeBtn = this.el.querySelector("[data-share-native]");
    if (nativeBtn) {
      nativeBtn.classList.remove("hidden");
      nativeBtn.addEventListener("click", async () => {
        if (navigator.share) {
          try {
            await navigator.share({ title, text, url });
            return;
          } catch (err) {
            if (err.name === "AbortError") return;
          }
        }
        // Fallback: copy link to clipboard
        try {
          await navigator.clipboard.writeText(url);
          const label = nativeBtn.querySelector(".share-label");
          if (label) {
            const original = label.textContent;
            label.textContent = "Link copied!";
            setTimeout(() => (label.textContent = original), 1500);
          }
        } catch (err) {
          console.error(err);
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
