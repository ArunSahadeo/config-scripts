var page = require('webpage').create(), config = require('./config.json');

page.settings.userAgent = 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/37.0.2062.120 Safari/537.36';

page.viewportSize = {
  width: config.width,
  height: config.height
};


function login_callback (status) {
    if (status != "success") {
        console.log("Failure loading login page");
        return
    }

    page.onLoadFinished = post_login_callback;

    page.evaluate(function () {
        document.querySelector(config.userfield).value=config.username;
        document.querySelector(config.passfield).value=config.password;
        document.querySelector(config.formSel).submit();
    });
}

function post_login_callback (status) {
    if (status != "success") {
        console.log("Failure logging in");
        return
    }

    page.onLoadFinished = render_page;

    page.open(config.redirectURI);
}

function render_page (status) {
    
    window.setTimeout(function () {
    console.log("Rendering to " + config.folder + " folder...");
    page.render(config.folder + "/" + config.outputFile);
    phantom.exit();
    }, config.timeout);

}

page.onLoadFinished = login_callback;
page.open(config.initialPage);
