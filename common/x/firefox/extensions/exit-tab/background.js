browser.omnibox.onInputEntered.addListener((text) => {
  if (text.toLowerCase() === 'exit') {
    browser.tabs.query({active: true, currentWindow: true}).then((tabs) => {
      if (tabs[0]) {
        browser.tabs.remove(tabs[0].id);
      }
    });
  }
}); 