import gleam/list
import gleam/option.{type Option, None, Some}

pub opaque type ReadOnlyDeque(a) {
  ReadOnlyDeque(lst: List(a), lst_rev: List(a), len: Int)
}

pub fn from_list(lst: List(a)) -> ReadOnlyDeque(a) {
  let lst_rev = list.reverse(lst)
  ReadOnlyDeque(lst, lst_rev, list.length(lst))
}

pub fn peek_front(fsd: ReadOnlyDeque(a)) -> Option(a) {
  case fsd.lst {
    [] -> None
    [item, ..] -> Some(item)
  }
}

pub fn peek_back(fsd: ReadOnlyDeque(a)) -> Option(a) {
  case fsd.lst_rev {
    [] -> None
    [item, ..] -> Some(item)
  }
}

pub fn pop_front(fsd: ReadOnlyDeque(a)) -> Option(#(a, ReadOnlyDeque(a))) {
  let ReadOnlyDeque(lst, lst_rev, len) = fsd
  case len, lst {
    0, _ | _, [] -> None
    _, [head, ..rest] -> Some(#(head, ReadOnlyDeque(rest, lst_rev, len - 1)))
  }
}

pub fn pop_back(fsd: ReadOnlyDeque(a)) -> Option(#(a, ReadOnlyDeque(a))) {
  let ReadOnlyDeque(lst, lst_rev, len) = fsd
  case len, lst_rev {
    0, _ | _, [] -> None
    _, [head, ..rest] -> Some(#(head, ReadOnlyDeque(lst, rest, len - 1)))
  }
}

pub fn is_empty(fsd: ReadOnlyDeque(a)) -> Bool {
  fsd.len == 0
}
