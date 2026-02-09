import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

/// 统一管理应用字体
public enum AppFont {

    public static var displayXL: Font { .custom("Quicksand-Bold",   size: 34, relativeTo: .largeTitle) }
    public static var displayXXL: Font { .custom("Quicksand-Bold",   size: 70, relativeTo: .largeTitle) }

    public static var displayL : Font { .custom("Quicksand-Bold",   size: 32, relativeTo: .title)      }
    public static var headingM : Font { .custom("Quicksand-Bold", size: 24, relativeTo: .title2)     }
    public static var headingL : Font { .custom("Quicksand-Bold", size: 20, relativeTo: .title3)     }
    public static var headingS : Font { .custom("Quicksand-Bold", size: 16, relativeTo: .title3)     }
    public static var bodyL    : Font { .custom("Quicksand-Regular",size: 16, relativeTo: .body)       }
    public static var bodyM1    : Font { .custom("Quicksand-Medium",size: 18, relativeTo: .subheadline)       }
    public static var bodyM    : Font { .custom("Quicksand-Medium",size: 16, relativeTo: .subheadline)       }
    public static var bodyS    : Font { .custom("Quicksand-Medium",size: 14, relativeTo: .callout)    }
    public static var caption  : Font { .custom("Quicksand-Medium", size: 12, relativeTo: .caption)    }
    public static var footnote : Font { .custom("Quicksand-Regular",size: 12, relativeTo: .footnote)   }
    public static var footnote2 : Font { .custom("Quicksand-Regular",size: 14, relativeTo: .footnote)   }

    #if canImport(UIKit)
    public enum ui {
        public static func displayXL() -> UIFont { dynamic("Quicksand-Bold",   size: 34, style: .largeTitle) }
        public static func displayL () -> UIFont { dynamic("Quicksand-Bold",   size: 28, style: .title1)     }
        public static func headingM () -> UIFont { dynamic("Quicksand-Medium", size: 22, style: .title2)     }
        public static func headingS () -> UIFont { dynamic("Quicksand-Medium", size: 20, style: .title3)     }
        public static func bodyM    () -> UIFont { dynamic("Quicksand-Regular",size: 17, style: .body)       }
        public static func bodyS    () -> UIFont { dynamic("Quicksand-Regular",size: 15, style: .callout)    }
        public static func caption  () -> UIFont { dynamic("Quicksand-Medium", size: 13, style: .caption1)   }
        public static func footnote () -> UIFont { dynamic("Quicksand-Regular",size: 11, style: .footnote)   }

        private static func dynamic(_ name: String, size: CGFloat, style: UIFont.TextStyle) -> UIFont {
            let base = UIFont(name: name, size: size)!
            return UIFontMetrics(forTextStyle: style).scaledFont(for: base)
        }
    }
    #endif
}
