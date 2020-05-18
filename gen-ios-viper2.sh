usage="usage: $0 <projectName> <author> <moduleName>";

if [ $1 ] ; then 
  projectName=$1;
fi

if [ $2 ] ; then 
  author=$2;
fi

if [ $3 ] ; then 
  moduleName=$3;
fi

if [ -z $projectName ] ; then
  echo $usage; exit 1;
fi

if [ -z $author ] ; then
  echo $usage; exit 1;
fi

if [ -z $moduleName ] ; then
  echo $usage; exit 1;
fi

nowDate=$(date +%Y-%m-%d)
nowYear=$(date +%Y)

namespaceName="$moduleName"

echo """\
//
//  $namespaceName.swift
//  $projectName
//
//  Created by $author on $nowDate.
//  Copyright © $nowYear $author. All rights reserved.
//

import UIKit

enum $namespaceName {
  struct Params {
    
  }
  
  struct Result {
    
  }
  
  enum Err {
  }
    
  static func build(params: Params) -> UIViewController {
    let view = View()
    let interactor = Interactor()
    let wireframe = Wireframe(params: params, view: view)
    let presenter = Presenter(view: view, interactor: interactor, wireframe: wireframe)
    
    view.retainPresenter(presenter)
    
    return view
  }
}""" > $namespaceName.swift;

echo """\
//
//  $namespaceName+Wireframe.swift
//  $projectName
//
//  Created by $author on $nowDate.
//  Copyright © $nowYear $author. All rights reserved.
//

import Foundation

extension $namespaceName {
  class Wireframe: VIPER.Wireframe<Params, Result> {
  }
}""" > $namespaceName+Wireframe.swift

echo """\
//
//  $namespaceName+View.swift
//  $projectName
//
//  Created by $author on $nowDate.
//  Copyright © $nowYear $author. All rights reserved.
//

import Foundation

extension $namespaceName {
  class View: VIPER.View {
  }
}""" > $namespaceName+View.swift;

echo """\
//
//  $namespaceName+Presenter.swift
//  $projectName
//
//  Created by $author on $nowDate.
//  Copyright © $nowYear $author. All rights reserved.
//

import Foundation

extension $namespaceName {
  class Presenter: VIPER.Presenter<Params, Result> {
    var view: View? { _view as? View }
    var interactor: Interactor? { _interactor as? Interactor }
    var wireframe: Wireframe? { _wireframe as? Wireframe }
  }
}""" > $namespaceName+Presenter.swift;

echo """\
//
//  $namespaceName+Interactor.swift
//  $projectName
//
//  Created by $author on $nowDate.
//  Copyright © $nowYear $author. All rights reserved.
//

import Foundation

extension $namespaceName {
  class Interactor: VIPER.Interactor {
  }
}""" > $namespaceName+Interactor.swift;

exit 0;
