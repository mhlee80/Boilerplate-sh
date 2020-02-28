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

protocolsName="$moduleName"Protocols

coordinatorProtocolName="$moduleName"CoordinatorProtocol
viewProtocolName="$moduleName"ViewProtocol
viewModelProtocolName="$moduleName"ViewModelProtocol

coordinatorName="$moduleName"Coordinator
viewName="$moduleName"View
viewModelName="$moduleName"ViewModel

echo """\
//
//  $protocolsName.swift
//  $projectName
//
//  Created by $author on $nowDate.
//  Copyright © $nowYear $author. All rights reserved.
//

import Foundation

protocol $coordinatorProtocolName {
  static func createModule() -> $viewProtocolName
}

protocol $viewProtocolName {
  var viewModel: $viewModelProtocolName? { get set }
}

protocol $viewModelProtocolName {
  var coordinator: $coordinatorProtocolName? { get set } 
  func viewDidLoad()
}""" > $protocolsName.swift;


echo """\
//
//  $coordinatorName.swift
//  $projectName
//
//  Created by $author on $nowDate.
//  Copyright © $nowYear $author. All rights reserved.
//

import Foundation
import UIKit

class $coordinatorName: NSObject, $coordinatorProtocolName {
  static func createModule() -> $viewProtocolName {
    let view = $viewName()
    let viewModel = $viewModelName()
    let coordinator = $coordinatorName()

    view.viewModel = viewModel
    viewModel.coordinator = coordinator

    return view
  }
}""" > $coordinatorName.swift;


echo """\
//
//  $viewName.swift
//  $projectName
//
//  Created by $author on $nowDate.
//  Copyright © $nowYear $author. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class $viewName: UIViewController, $viewProtocolName {
  private var disposeBag = DisposeBag()
  
  var viewModel: $viewModelProtocolName? {
    didSet {
      setupBind()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.

    DispatchQueue.main.async { [weak self] in
      self?.viewModel?.viewDidLoad()
    }
  }
  
  private func setupBind() {
    disposeBag = DisposeBag()
  }
}""" > $viewName.swift;

echo """\
//
//  $viewModelName.swift
//  $projectName
//
//  Created by $author on $nowDate.
//  Copyright © $nowYear $author. All rights reserved.
//

import Foundation

class $viewModelName: NSObject, $viewModelProtocolName {
  var coordinator: $coordinatorProtocolName?
  func viewDidLoad() {
  }
}""" > $viewModelName.swift;

exit 0;
