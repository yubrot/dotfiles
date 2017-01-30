const history = Components
  .classes["@mozilla.org/browser/nav-history-service;1"]
  .getService(Components.interfaces.nsINavHistoryService);

const bookmarks = Components
  .classes["@mozilla.org/browser/nav-bookmarks-service;1"]
  .getService(Components.interfaces.nsINavBookmarksService);

const io = Components
  .classes["@mozilla.org/network/io-service;1"]
  .getService(Components.interfaces.nsIIOService);

// Exported configurations
const options = {
  "prevent_autofocus": true,
  "hints.chars": "hjklas df",
  "config_file_directory": "~/.config/vimfx",
  "mode.normal.history_back": "h",
  "mode.normal.history_forward": "l",
  "mode.normal.history_list": "",
  "mode.normal.scroll_left": "",
  "mode.normal.scroll_right": "",
  "mode.normal.scroll_down": "J",
  "mode.normal.scroll_up": "K",
  "mode.normal.scroll_page_down": "",
  "mode.normal.scroll_page_up": "",
  "mode.normal.scroll_half_page_down": "j",
  "mode.normal.scroll_half_page_up": "k",
  "mode.normal.mark_scroll_position": "",
  "mode.normal.scroll_to_mark": "",
  "mode.normal.tab_select_previous": "H",
  "mode.normal.tab_select_next": "L",
  "mode.normal.tab_select_oldest_unvisited": "",
  "mode.normal.tab_move_backward": "gH",
  "mode.normal.tab_move_forward": "gL",
  "mode.normal.tab_select_first": "",
  "mode.normal.tab_select_first_non_pinned": "",
  "mode.normal.tab_select_last": "",
  "mode.normal.tab_toggle_pinned": "m",
  "mode.normal.tab_close": "d",
  "mode.normal.tab_restore": "u",
  "mode.normal.tab_restore_list": "",
  "mode.normal.tab_close_to_end": "",
  "mode.normal.tab_close_other": "",
  "mode.normal.enter_mode_ignore": "<s-escape>",
  "mode.hints.rotate_markers_backward": "<space>",
  "custom.mode.normal.zoom_in": "zi",
  "custom.mode.normal.zoom_out": "zo",
  "custom.mode.normal.zoom_reset": "zz",
  "custom.mode.normal.qmarks_add": "qm",
  "custom.mode.normal.qmarks_remove": "qD",
  "custom.mode.normal.qmarks_open": "go",
  "custom.mode.normal.qmarks_open_in_tab": "gn",
}

function command(name, description, handler) {
  vimfx.addCommand({ name, description }, ({vim}) => handler(vim));
}

// Zoom commands
command('zoom_in', 'Zoom in', vim => {
  vim.window.FullZoom.enlarge();
});

command('zoom_out', 'Zoom out', vim => {
  vim.window.FullZoom.reduce();
});

command('zoom_reset', 'Zoom reset', vim => {
  vim.window.FullZoom.reset();
});

function folderItems(folder) {
  function itemToObject(item) {
    const obj = { id: item.itemId, title: item.title };
    switch (item.type) {
      case item.RESULT_TYPE_URI:
        obj.type = 'uri';
        obj.uri = item.uri;
        break;
      case item.RESULT_TYPE_FOLDER:
        obj.type = 'folder';
        break;
      case item.RESULT_TYPE_SEPARATOR:
        obj.type = 'separator';
        break;
      default:
        obj.type = 'other';
    }
    return obj;
  }

  const query = history.getNewQuery();
  query.setFolders([folder], 1);
  const node = history.executeQuery(query, history.getNewQueryOptions()).root;
  node.containerOpen = true;

  const ret = [];
  for (let i=0; i<node.childCount; ++i) ret.push(itemToObject(node.getChild(i)));
  return ret;
}

let qmarks;
{
  const item = folderItems(bookmarks.bookmarksMenuFolder).find(item => item.title == 'qmarks');
  if (item) {
    if (item.type != 'folder') console.warn('The item titled \'qmarks\' is not a folder');
    qmarks = item.id;

  } else {
    qmarks = bookmarks.createFolder(bookmarks.bookmarksMenuFolder, "qmarks", -1);
  }
}

function qmarksGet(key) {
  return folderItems(qmarks).find(item => item.title == key);
}

function qmarksSet(key, uri) {
  const item = qmarksGet(key);
  if (item) bookmarks.removeItem(item.id);
  if (uri) bookmarks.insertBookmark(qmarks, io.newURI(uri, null, null), -1, key);
}

command('qmarks_add', 'Add a quickmark', vim => {
  vim._enterMode('marks', keyStr => {
    const uri = vim.browser.currentURI.spec;
    qmarksSet(keyStr, uri);
    vim.notify('Added quickmark \'' + keyStr + '\': ' + uri);
  });
});

command('qmarks_remove', 'Remove the specified quickmark', vim => {
  vim._enterMode('marks', keyStr => {
    qmarksSet(keyStr, null);
    vim.notify('Removed quickmark \'' + keyStr + '\'');
  });
});

function qmarksOpen(inNewTab) {
  return vim => {
    vim._enterMode('marks', keyStr => {
      const item = qmarksGet(keyStr);
      if (item) {
        if (inNewTab) {
          vim.window.gBrowser.loadOneTab(item.uri, { inBackground: false });
        } else {
          vim.window.gBrowser.loadURI(item.uri);
        }

      } else {
        vim.notify('No quickmark named \'' + keyStr + '\'');
      }
    });
  };
}

command('qmarks_open', 'Open the specified quickmark', qmarksOpen(false));
command('qmarks_open_in_tab', 'Open the specified quickmark in a new tab', qmarksOpen(true));

for (const key in options) vimfx.set(key, options[key]);

