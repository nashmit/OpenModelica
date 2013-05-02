package TplCodegen

public import Tpl;

public import TplAbsyn;

protected function lm_3
  input Tpl.Text in_txt;
  input list<TplAbsyn.MMDeclaration> in_items;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_items)
    local
      Tpl.Text txt;
      list<TplAbsyn.MMDeclaration> rest;
      TplAbsyn.MMDeclaration i_it;

    case ( txt,
           {} )
      then txt;

    case ( txt,
           i_it :: rest )
      equation
        txt = mmDeclaration(txt, i_it);
        txt = Tpl.nextIter(txt);
        txt = lm_3(txt, rest);
      then txt;

    case ( txt,
           _ :: rest )
      equation
        txt = lm_3(txt, rest);
      then txt;
  end matchcontinue;
end lm_3;

public function mmPackage
  input Tpl.Text in_txt;
  input TplAbsyn.MMPackage in_a_it;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_a_it)
    local
      Tpl.Text txt;
      list<TplAbsyn.MMDeclaration> i_mmDeclarations;
      TplAbsyn.PathIdent i_name;

    case ( txt,
           TplAbsyn.MM_PACKAGE(name = i_name, mmDeclarations = i_mmDeclarations) )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("package "));
        txt = pathIdent(txt, i_name);
        txt = Tpl.softNewLine(txt);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING_LIST({
                                    "\n",
                                    "public import Tpl;\n",
                                    "\n"
                                }, true));
        txt = Tpl.pushIter(txt, Tpl.ITER_OPTIONS(0, NONE(), SOME(Tpl.ST_NEW_LINE()), 0, 0, Tpl.ST_NEW_LINE(), 0, Tpl.ST_NEW_LINE()));
        txt = lm_3(txt, i_mmDeclarations);
        txt = Tpl.popIter(txt);
        txt = Tpl.softNewLine(txt);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING_LIST({
                                    "\n",
                                    "end "
                                }, false));
        txt = pathIdent(txt, i_name);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(";"));
      then txt;

    case ( txt,
           _ )
      then txt;
  end matchcontinue;
end mmPackage;

protected function fun_5
  input Tpl.Text in_txt;
  input TplAbsyn.TypedIdents in_a_mf_locals;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_a_mf_locals)
    local
      Tpl.Text txt;
      TplAbsyn.TypedIdents i_mf_locals;

    case ( txt,
           {} )
      then txt;

    case ( txt,
           i_mf_locals )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_LINE("protected\n"));
        txt = Tpl.pushBlock(txt, Tpl.BT_INDENT(2));
        txt = typedIdents(txt, i_mf_locals);
        txt = Tpl.popBlock(txt);
      then txt;
  end matchcontinue;
end fun_5;

protected function lm_6
  input Tpl.Text in_txt;
  input list<TplAbsyn.MMExp> in_items;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_items)
    local
      Tpl.Text txt;
      list<TplAbsyn.MMExp> rest;
      TplAbsyn.MMExp i_it;

    case ( txt,
           {} )
      then txt;

    case ( txt,
           i_it :: rest )
      equation
        txt = mmExp(txt, i_it, ":=");
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(";"));
        txt = Tpl.nextIter(txt);
        txt = lm_6(txt, rest);
      then txt;

    case ( txt,
           _ :: rest )
      equation
        txt = lm_6(txt, rest);
      then txt;
  end matchcontinue;
end lm_6;

protected function fun_7
  input Tpl.Text in_txt;
  input list<TplAbsyn.MMExp> in_a_statements;
  input TplAbsyn.TypedIdents in_a_mf_locals;
  input TplAbsyn.TypedIdents in_a_mf_outArgs;
  input TplAbsyn.TypedIdents in_a_mf_inArgs;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_a_statements, in_a_mf_locals, in_a_mf_outArgs, in_a_mf_inArgs)
    local
      Tpl.Text txt;
      TplAbsyn.TypedIdents a_mf_locals;
      TplAbsyn.TypedIdents a_mf_outArgs;
      TplAbsyn.TypedIdents a_mf_inArgs;
      list<TplAbsyn.MMExp> i_sts;
      list<TplAbsyn.MMMatchCase> i_c_matchCases;

    case ( txt,
           {TplAbsyn.MM_MATCH(matchCases = i_c_matchCases)},
           a_mf_locals,
           a_mf_outArgs,
           a_mf_inArgs )
      equation
        txt = mmMatchFunBody(txt, a_mf_inArgs, a_mf_outArgs, a_mf_locals, i_c_matchCases);
      then txt;

    case ( txt,
           i_sts,
           a_mf_locals,
           a_mf_outArgs,
           a_mf_inArgs )
      equation
        txt = Tpl.pushBlock(txt, Tpl.BT_INDENT(2));
        txt = typedIdentsEx(txt, a_mf_inArgs, "input", "");
        txt = Tpl.softNewLine(txt);
        txt = Tpl.writeTok(txt, Tpl.ST_NEW_LINE());
        txt = typedIdentsEx(txt, a_mf_outArgs, "output", "out_");
        txt = Tpl.softNewLine(txt);
        txt = Tpl.popBlock(txt);
        txt = fun_5(txt, a_mf_locals);
        txt = Tpl.softNewLine(txt);
        txt = Tpl.writeTok(txt, Tpl.ST_LINE("algorithm\n"));
        txt = Tpl.pushBlock(txt, Tpl.BT_INDENT(2));
        txt = Tpl.pushIter(txt, Tpl.ITER_OPTIONS(0, NONE(), SOME(Tpl.ST_NEW_LINE()), 0, 0, Tpl.ST_NEW_LINE(), 0, Tpl.ST_NEW_LINE()));
        txt = lm_6(txt, i_sts);
        txt = Tpl.popIter(txt);
        txt = Tpl.popBlock(txt);
      then txt;
  end matchcontinue;
end fun_7;

public function mmDeclaration
  input Tpl.Text in_txt;
  input TplAbsyn.MMDeclaration in_a_it;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_a_it)
    local
      Tpl.Text txt;
      TplAbsyn.TypedIdents i_mf_locals;
      TplAbsyn.TypedIdents i_mf_outArgs;
      TplAbsyn.TypedIdents i_mf_inArgs;
      list<TplAbsyn.MMExp> i_statements;
      String i_value_1;
      TplAbsyn.TypeSignature i_litType;
      TplAbsyn.StringToken i_value;
      TplAbsyn.Ident i_name;
      TplAbsyn.PathIdent i_packageName;
      Boolean i_isPublic;

    case ( txt,
           TplAbsyn.MM_IMPORT(packageName = TplAbsyn.IDENT(ident = "Tpl")) )
      then txt;

    case ( txt,
           TplAbsyn.MM_IMPORT(packageName = TplAbsyn.IDENT(ident = "builtin")) )
      then txt;

    case ( txt,
           TplAbsyn.MM_IMPORT(isPublic = i_isPublic, packageName = i_packageName) )
      equation
        txt = mmPublic(txt, i_isPublic);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(" import "));
        txt = pathIdent(txt, i_packageName);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(";"));
      then txt;

    case ( txt,
           TplAbsyn.MM_STR_TOKEN_DECL(isPublic = i_isPublic, name = i_name, value = i_value) )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_NEW_LINE());
        txt = mmPublic(txt, i_isPublic);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(" constant Tpl.StringToken "));
        txt = Tpl.writeStr(txt, i_name);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(" = "));
        txt = mmStringTokenConstant(txt, i_value);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(";"));
      then txt;

    case ( txt,
           TplAbsyn.MM_LITERAL_DECL(isPublic = i_isPublic, litType = i_litType, name = i_name, value = i_value_1) )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_NEW_LINE());
        txt = mmPublic(txt, i_isPublic);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(" constant "));
        txt = typeSig(txt, i_litType);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(" "));
        txt = Tpl.writeStr(txt, i_name);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(" = "));
        txt = Tpl.writeStr(txt, i_value_1);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(";"));
      then txt;

    case ( txt,
           TplAbsyn.MM_FUN(isPublic = i_isPublic, name = i_name, statements = i_statements, inArgs = i_mf_inArgs, outArgs = i_mf_outArgs, locals = i_mf_locals) )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_NEW_LINE());
        txt = mmPublic(txt, i_isPublic);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(" function "));
        txt = Tpl.writeStr(txt, i_name);
        txt = Tpl.softNewLine(txt);
        txt = fun_7(txt, i_statements, i_mf_locals, i_mf_outArgs, i_mf_inArgs);
        txt = Tpl.softNewLine(txt);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("end "));
        txt = Tpl.writeStr(txt, i_name);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(";"));
      then txt;

    case ( txt,
           _ )
      then txt;
  end matchcontinue;
end mmDeclaration;

protected function lm_9
  input Tpl.Text in_txt;
  input TplAbsyn.TypedIdents in_items;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_items)
    local
      Tpl.Text txt;
      TplAbsyn.TypedIdents rest;
      TplAbsyn.Ident i_nm;

    case ( txt,
           {} )
      then txt;

    case ( txt,
           (i_nm, _) :: rest )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("out_"));
        txt = Tpl.writeStr(txt, i_nm);
        txt = Tpl.nextIter(txt);
        txt = lm_9(txt, rest);
      then txt;

    case ( txt,
           _ :: rest )
      equation
        txt = lm_9(txt, rest);
      then txt;
  end matchcontinue;
end lm_9;

protected function fun_10
  input Tpl.Text in_txt;
  input TplAbsyn.TypedIdents in_a_outArgs;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_a_outArgs)
    local
      Tpl.Text txt;
      TplAbsyn.TypedIdents i_outArgs;
      TplAbsyn.Ident i_nm;

    case ( txt,
           {(i_nm, _)} )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("out_"));
        txt = Tpl.writeStr(txt, i_nm);
      then txt;

    case ( txt,
           i_outArgs )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("("));
        txt = Tpl.pushIter(txt, Tpl.ITER_OPTIONS(0, NONE(), SOME(Tpl.ST_STRING(", ")), 0, 0, Tpl.ST_NEW_LINE(), 0, Tpl.ST_NEW_LINE()));
        txt = lm_9(txt, i_outArgs);
        txt = Tpl.popIter(txt);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(")"));
      then txt;
  end matchcontinue;
end fun_10;

protected function lm_11
  input Tpl.Text in_txt;
  input TplAbsyn.TypedIdents in_items;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_items)
    local
      Tpl.Text txt;
      TplAbsyn.TypedIdents rest;
      TplAbsyn.Ident i_nm;

    case ( txt,
           {} )
      then txt;

    case ( txt,
           (i_nm, _) :: rest )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("in_"));
        txt = Tpl.writeStr(txt, i_nm);
        txt = Tpl.nextIter(txt);
        txt = lm_11(txt, rest);
      then txt;

    case ( txt,
           _ :: rest )
      equation
        txt = lm_11(txt, rest);
      then txt;
  end matchcontinue;
end lm_11;

protected function lm_12
  input Tpl.Text in_txt;
  input list<TplAbsyn.MatchingExp> in_items;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_items)
    local
      Tpl.Text txt;
      list<TplAbsyn.MatchingExp> rest;
      TplAbsyn.MatchingExp i_it;

    case ( txt,
           {} )
      then txt;

    case ( txt,
           i_it :: rest )
      equation
        txt = mmMatchingExp(txt, i_it);
        txt = Tpl.nextIter(txt);
        txt = lm_12(txt, rest);
      then txt;

    case ( txt,
           _ :: rest )
      equation
        txt = lm_12(txt, rest);
      then txt;
  end matchcontinue;
end lm_12;

protected function lm_13
  input Tpl.Text in_txt;
  input list<TplAbsyn.MMExp> in_items;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_items)
    local
      Tpl.Text txt;
      list<TplAbsyn.MMExp> rest;
      TplAbsyn.MMExp i_it;

    case ( txt,
           {} )
      then txt;

    case ( txt,
           i_it :: rest )
      equation
        txt = mmExp(txt, i_it, "=");
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(";"));
        txt = Tpl.nextIter(txt);
        txt = lm_13(txt, rest);
      then txt;

    case ( txt,
           _ :: rest )
      equation
        txt = lm_13(txt, rest);
      then txt;
  end matchcontinue;
end lm_13;

protected function fun_14
  input Tpl.Text in_txt;
  input list<TplAbsyn.MMExp> in_a_statements;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_a_statements)
    local
      Tpl.Text txt;
      list<TplAbsyn.MMExp> i_statements;

    case ( txt,
           {} )
      then txt;

    case ( txt,
           i_statements )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_LINE("equation\n"));
        txt = Tpl.pushBlock(txt, Tpl.BT_INDENT(2));
        txt = Tpl.pushIter(txt, Tpl.ITER_OPTIONS(0, NONE(), SOME(Tpl.ST_NEW_LINE()), 0, 0, Tpl.ST_NEW_LINE(), 0, Tpl.ST_NEW_LINE()));
        txt = lm_13(txt, i_statements);
        txt = Tpl.popIter(txt);
        txt = Tpl.popBlock(txt);
      then txt;
  end matchcontinue;
end fun_14;

protected function lm_15
  input Tpl.Text in_txt;
  input TplAbsyn.TypedIdents in_items;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_items)
    local
      Tpl.Text txt;
      TplAbsyn.TypedIdents rest;
      TplAbsyn.Ident i_nm;

    case ( txt,
           {} )
      then txt;

    case ( txt,
           (i_nm, _) :: rest )
      equation
        txt = Tpl.writeStr(txt, i_nm);
        txt = Tpl.nextIter(txt);
        txt = lm_15(txt, rest);
      then txt;

    case ( txt,
           _ :: rest )
      equation
        txt = lm_15(txt, rest);
      then txt;
  end matchcontinue;
end lm_15;

protected function fun_16
  input Tpl.Text in_txt;
  input TplAbsyn.TypedIdents in_a_outArgs;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_a_outArgs)
    local
      Tpl.Text txt;
      TplAbsyn.TypedIdents i_oas;
      TplAbsyn.Ident i_nm;

    case ( txt,
           {(i_nm, _)} )
      equation
        txt = Tpl.writeStr(txt, i_nm);
      then txt;

    case ( txt,
           i_oas )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("("));
        txt = Tpl.pushIter(txt, Tpl.ITER_OPTIONS(0, NONE(), SOME(Tpl.ST_STRING(", ")), 0, 0, Tpl.ST_NEW_LINE(), 0, Tpl.ST_NEW_LINE()));
        txt = lm_15(txt, i_oas);
        txt = Tpl.popIter(txt);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(")"));
      then txt;
  end matchcontinue;
end fun_16;

protected function lm_17
  input Tpl.Text in_txt;
  input list<TplAbsyn.MMMatchCase> in_items;
  input TplAbsyn.TypedIdents in_a_outArgs;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_items, in_a_outArgs)
    local
      Tpl.Text txt;
      list<TplAbsyn.MMMatchCase> rest;
      TplAbsyn.TypedIdents a_outArgs;
      list<TplAbsyn.MMExp> i_statements;
      list<TplAbsyn.MatchingExp> i_mexps;

    case ( txt,
           {},
           _ )
      then txt;

    case ( txt,
           (i_mexps, i_statements) :: rest,
           a_outArgs )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_NEW_LINE());
        txt = Tpl.pushBlock(txt, Tpl.BT_INDENT(2));
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("case ( "));
        txt = Tpl.pushBlock(txt, Tpl.BT_ANCHOR(0));
        txt = Tpl.pushIter(txt, Tpl.ITER_OPTIONS(0, NONE(), SOME(Tpl.ST_LINE(",\n")), 0, 0, Tpl.ST_NEW_LINE(), 0, Tpl.ST_NEW_LINE()));
        txt = lm_12(txt, i_mexps);
        txt = Tpl.popIter(txt);
        txt = Tpl.popBlock(txt);
        txt = Tpl.writeTok(txt, Tpl.ST_LINE(" )\n"));
        txt = Tpl.pushBlock(txt, Tpl.BT_INDENT(2));
        txt = fun_14(txt, i_statements);
        txt = Tpl.softNewLine(txt);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("then "));
        txt = fun_16(txt, a_outArgs);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(";"));
        txt = Tpl.popBlock(txt);
        txt = Tpl.popBlock(txt);
        txt = Tpl.nextIter(txt);
        txt = lm_17(txt, rest, a_outArgs);
      then txt;

    case ( txt,
           _ :: rest,
           a_outArgs )
      equation
        txt = lm_17(txt, rest, a_outArgs);
      then txt;
  end matchcontinue;
end lm_17;

public function mmMatchFunBody
  input Tpl.Text txt;
  input TplAbsyn.TypedIdents a_inArgs;
  input TplAbsyn.TypedIdents a_outArgs;
  input TplAbsyn.TypedIdents a_locals;
  input list<TplAbsyn.MMMatchCase> a_matchCases;

  output Tpl.Text out_txt;
algorithm
  out_txt := Tpl.pushBlock(txt, Tpl.BT_INDENT(2));
  out_txt := typedIdentsEx(out_txt, a_inArgs, "input", "in_");
  out_txt := Tpl.softNewLine(out_txt);
  out_txt := Tpl.writeTok(out_txt, Tpl.ST_NEW_LINE());
  out_txt := typedIdentsEx(out_txt, a_outArgs, "output", "out_");
  out_txt := Tpl.softNewLine(out_txt);
  out_txt := Tpl.popBlock(out_txt);
  out_txt := Tpl.writeTok(out_txt, Tpl.ST_LINE("algorithm\n"));
  out_txt := Tpl.pushBlock(out_txt, Tpl.BT_INDENT(2));
  out_txt := fun_10(out_txt, a_outArgs);
  out_txt := Tpl.writeTok(out_txt, Tpl.ST_STRING_LIST({
                                       " :=\n",
                                       "matchcontinue("
                                   }, false));
  out_txt := Tpl.pushIter(out_txt, Tpl.ITER_OPTIONS(0, NONE(), SOME(Tpl.ST_STRING(", ")), 0, 0, Tpl.ST_NEW_LINE(), 0, Tpl.ST_NEW_LINE()));
  out_txt := lm_11(out_txt, a_inArgs);
  out_txt := Tpl.popIter(out_txt);
  out_txt := Tpl.writeTok(out_txt, Tpl.ST_STRING_LIST({
                                       ")\n",
                                       "  local\n"
                                   }, true));
  out_txt := Tpl.pushBlock(out_txt, Tpl.BT_INDENT(4));
  out_txt := typedIdents(out_txt, a_locals);
  out_txt := Tpl.softNewLine(out_txt);
  out_txt := Tpl.popBlock(out_txt);
  out_txt := Tpl.pushIter(out_txt, Tpl.ITER_OPTIONS(0, NONE(), SOME(Tpl.ST_NEW_LINE()), 0, 0, Tpl.ST_NEW_LINE(), 0, Tpl.ST_NEW_LINE()));
  out_txt := lm_17(out_txt, a_matchCases, a_outArgs);
  out_txt := Tpl.popIter(out_txt);
  out_txt := Tpl.softNewLine(out_txt);
  out_txt := Tpl.writeTok(out_txt, Tpl.ST_STRING("end matchcontinue;"));
  out_txt := Tpl.popBlock(out_txt);
end mmMatchFunBody;

public function pathIdent
  input Tpl.Text in_txt;
  input TplAbsyn.PathIdent in_a_path;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_a_path)
    local
      Tpl.Text txt;
      TplAbsyn.PathIdent i_path;
      TplAbsyn.Ident i_ident;

    case ( txt,
           TplAbsyn.IDENT(ident = i_ident) )
      equation
        txt = Tpl.writeStr(txt, i_ident);
      then txt;

    case ( txt,
           TplAbsyn.PATH_IDENT(ident = i_ident, path = i_path) )
      equation
        txt = Tpl.writeStr(txt, i_ident);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("."));
        txt = pathIdent(txt, i_path);
      then txt;

    case ( txt,
           _ )
      then txt;
  end matchcontinue;
end pathIdent;

public function mmPublic
  input Tpl.Text in_txt;
  input Boolean in_a_it;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_a_it)
    local
      Tpl.Text txt;

    case ( txt,
           true )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("public"));
      then txt;

    case ( txt,
           _ )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("protected"));
      then txt;
  end matchcontinue;
end mmPublic;

protected function lm_21
  input Tpl.Text in_txt;
  input TplAbsyn.TypedIdents in_items;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_items)
    local
      Tpl.Text txt;
      TplAbsyn.TypedIdents rest;
      TplAbsyn.Ident i_id;
      TplAbsyn.TypeSignature i_ts;

    case ( txt,
           {} )
      then txt;

    case ( txt,
           (i_id, i_ts) :: rest )
      equation
        txt = typeSig(txt, i_ts);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(" "));
        txt = Tpl.writeStr(txt, i_id);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(";"));
        txt = Tpl.nextIter(txt);
        txt = lm_21(txt, rest);
      then txt;

    case ( txt,
           _ :: rest )
      equation
        txt = lm_21(txt, rest);
      then txt;
  end matchcontinue;
end lm_21;

public function typedIdents
  input Tpl.Text txt;
  input TplAbsyn.TypedIdents a_decls;

  output Tpl.Text out_txt;
algorithm
  out_txt := Tpl.pushIter(txt, Tpl.ITER_OPTIONS(0, NONE(), SOME(Tpl.ST_NEW_LINE()), 0, 0, Tpl.ST_NEW_LINE(), 0, Tpl.ST_NEW_LINE()));
  out_txt := lm_21(out_txt, a_decls);
  out_txt := Tpl.popIter(out_txt);
end typedIdents;

protected function lm_23
  input Tpl.Text in_txt;
  input TplAbsyn.TypedIdents in_items;
  input String in_a_idPrfx;
  input String in_a_typePrfx;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_items, in_a_idPrfx, in_a_typePrfx)
    local
      Tpl.Text txt;
      TplAbsyn.TypedIdents rest;
      String a_idPrfx;
      String a_typePrfx;
      TplAbsyn.Ident i_id;
      TplAbsyn.TypeSignature i_ty;

    case ( txt,
           {},
           _,
           _ )
      then txt;

    case ( txt,
           (i_id, i_ty) :: rest,
           a_idPrfx,
           a_typePrfx )
      equation
        txt = Tpl.writeStr(txt, a_typePrfx);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(" "));
        txt = typeSig(txt, i_ty);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(" "));
        txt = Tpl.writeStr(txt, a_idPrfx);
        txt = Tpl.writeStr(txt, i_id);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(";"));
        txt = Tpl.nextIter(txt);
        txt = lm_23(txt, rest, a_idPrfx, a_typePrfx);
      then txt;

    case ( txt,
           _ :: rest,
           a_idPrfx,
           a_typePrfx )
      equation
        txt = lm_23(txt, rest, a_idPrfx, a_typePrfx);
      then txt;
  end matchcontinue;
end lm_23;

public function typedIdentsEx
  input Tpl.Text txt;
  input TplAbsyn.TypedIdents a_decls;
  input String a_typePrfx;
  input String a_idPrfx;

  output Tpl.Text out_txt;
algorithm
  out_txt := Tpl.pushIter(txt, Tpl.ITER_OPTIONS(0, NONE(), SOME(Tpl.ST_NEW_LINE()), 0, 0, Tpl.ST_NEW_LINE(), 0, Tpl.ST_NEW_LINE()));
  out_txt := lm_23(out_txt, a_decls, a_idPrfx, a_typePrfx);
  out_txt := Tpl.popIter(out_txt);
end typedIdentsEx;

protected function lm_25
  input Tpl.Text in_txt;
  input list<TplAbsyn.TypeSignature> in_items;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_items)
    local
      Tpl.Text txt;
      list<TplAbsyn.TypeSignature> rest;
      TplAbsyn.TypeSignature i_it;

    case ( txt,
           {} )
      then txt;

    case ( txt,
           i_it :: rest )
      equation
        txt = typeSig(txt, i_it);
        txt = Tpl.nextIter(txt);
        txt = lm_25(txt, rest);
      then txt;

    case ( txt,
           _ :: rest )
      equation
        txt = lm_25(txt, rest);
      then txt;
  end matchcontinue;
end lm_25;

public function typeSig
  input Tpl.Text in_txt;
  input TplAbsyn.TypeSignature in_a_it;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_a_it)
    local
      Tpl.Text txt;
      String i_reason;
      TplAbsyn.PathIdent i_name;
      list<TplAbsyn.TypeSignature> i_ofTypes;
      TplAbsyn.TypeSignature i_ofType;

    case ( txt,
           TplAbsyn.LIST_TYPE(ofType = i_ofType) )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("list<"));
        txt = typeSig(txt, i_ofType);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(">"));
      then txt;

    case ( txt,
           TplAbsyn.ARRAY_TYPE(ofType = i_ofType) )
      equation
        txt = typeSig(txt, i_ofType);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("[:]"));
      then txt;

    case ( txt,
           TplAbsyn.OPTION_TYPE(ofType = i_ofType) )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("Option<"));
        txt = typeSig(txt, i_ofType);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(">"));
      then txt;

    case ( txt,
           TplAbsyn.TUPLE_TYPE(ofTypes = i_ofTypes) )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("tuple<"));
        txt = Tpl.pushIter(txt, Tpl.ITER_OPTIONS(0, NONE(), SOME(Tpl.ST_STRING(", ")), 0, 0, Tpl.ST_NEW_LINE(), 0, Tpl.ST_NEW_LINE()));
        txt = lm_25(txt, i_ofTypes);
        txt = Tpl.popIter(txt);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(">"));
      then txt;

    case ( txt,
           TplAbsyn.NAMED_TYPE(name = i_name) )
      equation
        txt = pathIdent(txt, i_name);
      then txt;

    case ( txt,
           TplAbsyn.STRING_TYPE() )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("String"));
      then txt;

    case ( txt,
           TplAbsyn.TEXT_TYPE() )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("Tpl.Text"));
      then txt;

    case ( txt,
           TplAbsyn.STRING_TOKEN_TYPE() )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("Tpl.StringToken"));
      then txt;

    case ( txt,
           TplAbsyn.INTEGER_TYPE() )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("Integer"));
      then txt;

    case ( txt,
           TplAbsyn.REAL_TYPE() )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("Real"));
      then txt;

    case ( txt,
           TplAbsyn.BOOLEAN_TYPE() )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("Boolean"));
      then txt;

    case ( txt,
           TplAbsyn.UNRESOLVED_TYPE(reason = i_reason) )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("#type? "));
        txt = Tpl.writeStr(txt, i_reason);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(" ?#"));
      then txt;

    case ( txt,
           _ )
      then txt;
  end matchcontinue;
end typeSig;

protected function lm_27
  input Tpl.Text in_txt;
  input list<String> in_items;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_items)
    local
      Tpl.Text txt;
      list<String> rest;
      String i_it;

    case ( txt,
           {} )
      then txt;

    case ( txt,
           i_it :: rest )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("\""));
        txt = mmEscapeStringConst(txt, i_it, true);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("\""));
        txt = Tpl.nextIter(txt);
        txt = lm_27(txt, rest);
      then txt;

    case ( txt,
           _ :: rest )
      equation
        txt = lm_27(txt, rest);
      then txt;
  end matchcontinue;
end lm_27;

public function mmStringTokenConstant
  input Tpl.Text in_txt;
  input Tpl.StringToken in_a_it;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_a_it)
    local
      Tpl.Text txt;
      Boolean i_lastHasNewLine;
      list<String> i_strList;
      String i_line;
      String i_value;

    case ( txt,
           Tpl.ST_NEW_LINE() )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("Tpl.ST_NEW_LINE()"));
      then txt;

    case ( txt,
           Tpl.ST_STRING(value = i_value) )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("Tpl.ST_STRING(\""));
        txt = mmEscapeStringConst(txt, i_value, true);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("\")"));
      then txt;

    case ( txt,
           Tpl.ST_LINE(line = i_line) )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("Tpl.ST_LINE(\""));
        txt = mmEscapeStringConst(txt, i_line, true);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("\")"));
      then txt;

    case ( txt,
           Tpl.ST_STRING_LIST(strList = i_strList, lastHasNewLine = i_lastHasNewLine) )
      equation
        txt = Tpl.pushBlock(txt, Tpl.BT_ANCHOR(0));
        txt = Tpl.writeTok(txt, Tpl.ST_LINE("Tpl.ST_STRING_LIST({\n"));
        txt = Tpl.pushBlock(txt, Tpl.BT_INDENT(4));
        txt = Tpl.pushIter(txt, Tpl.ITER_OPTIONS(0, NONE(), SOME(Tpl.ST_LINE(",\n")), 0, 0, Tpl.ST_NEW_LINE(), 0, Tpl.ST_NEW_LINE()));
        txt = lm_27(txt, i_strList);
        txt = Tpl.popIter(txt);
        txt = Tpl.softNewLine(txt);
        txt = Tpl.popBlock(txt);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("}, "));
        txt = Tpl.writeStr(txt, Tpl.booleanString(i_lastHasNewLine));
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(")"));
        txt = Tpl.popBlock(txt);
      then txt;

    case ( txt,
           _ )
      then txt;
  end matchcontinue;
end mmStringTokenConstant;

protected function fun_29
  input Tpl.Text in_txt;
  input Boolean in_a_escapeNewLine;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_a_escapeNewLine)
    local
      Tpl.Text txt;

    case ( txt,
           false )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_NEW_LINE());
      then txt;

    case ( txt,
           _ )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("\\n"));
      then txt;
  end matchcontinue;
end fun_29;

protected function fun_30
  input Tpl.Text in_txt;
  input String in_a_it;
  input Boolean in_a_escapeNewLine;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_a_it, in_a_escapeNewLine)
    local
      Tpl.Text txt;
      Boolean a_escapeNewLine;
      String i_c;

    case ( txt,
           "\\",
           _ )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("\\\\"));
      then txt;

    case ( txt,
           "\'",
           _ )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("\\\'"));
      then txt;

    case ( txt,
           "\"",
           _ )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("\\\""));
      then txt;

    case ( txt,
           "\n",
           a_escapeNewLine )
      equation
        txt = fun_29(txt, a_escapeNewLine);
      then txt;

    case ( txt,
           "\t",
           _ )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("\\t"));
      then txt;

    case ( txt,
           i_c,
           _ )
      equation
        txt = Tpl.writeStr(txt, i_c);
      then txt;
  end matchcontinue;
end fun_30;

protected function lm_31
  input Tpl.Text in_txt;
  input list<String> in_items;
  input Boolean in_a_escapeNewLine;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_items, in_a_escapeNewLine)
    local
      Tpl.Text txt;
      list<String> rest;
      Boolean a_escapeNewLine;
      String i_it;

    case ( txt,
           {},
           _ )
      then txt;

    case ( txt,
           i_it :: rest,
           a_escapeNewLine )
      equation
        txt = fun_30(txt, i_it, a_escapeNewLine);
        txt = lm_31(txt, rest, a_escapeNewLine);
      then txt;

    case ( txt,
           _ :: rest,
           a_escapeNewLine )
      equation
        txt = lm_31(txt, rest, a_escapeNewLine);
      then txt;
  end matchcontinue;
end lm_31;

public function mmEscapeStringConst
  input Tpl.Text txt;
  input String a_internalValue;
  input Boolean a_escapeNewLine;

  output Tpl.Text out_txt;
protected
  list<String> ret_0;
algorithm
  ret_0 := stringListStringChar(a_internalValue);
  out_txt := lm_31(txt, ret_0, a_escapeNewLine);
end mmEscapeStringConst;

protected function lm_33
  input Tpl.Text in_txt;
  input list<TplAbsyn.Ident> in_items;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_items)
    local
      Tpl.Text txt;
      list<TplAbsyn.Ident> rest;
      TplAbsyn.Ident i_it;

    case ( txt,
           {} )
      then txt;

    case ( txt,
           i_it :: rest )
      equation
        txt = Tpl.writeStr(txt, i_it);
        txt = Tpl.nextIter(txt);
        txt = lm_33(txt, rest);
      then txt;

    case ( txt,
           _ :: rest )
      equation
        txt = lm_33(txt, rest);
      then txt;
  end matchcontinue;
end lm_33;

protected function fun_34
  input Tpl.Text in_txt;
  input list<TplAbsyn.Ident> in_a_lhsArgs;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_a_lhsArgs)
    local
      Tpl.Text txt;
      list<TplAbsyn.Ident> i_args;
      TplAbsyn.Ident i_id;

    case ( txt,
           {i_id} )
      equation
        txt = Tpl.writeStr(txt, i_id);
      then txt;

    case ( txt,
           i_args )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("("));
        txt = Tpl.pushIter(txt, Tpl.ITER_OPTIONS(0, NONE(), SOME(Tpl.ST_STRING(", ")), 0, 0, Tpl.ST_NEW_LINE(), 0, Tpl.ST_NEW_LINE()));
        txt = lm_33(txt, i_args);
        txt = Tpl.popIter(txt);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(")"));
      then txt;
  end matchcontinue;
end fun_34;

protected function lm_35
  input Tpl.Text in_txt;
  input list<TplAbsyn.MMExp> in_items;
  input String in_a_assignStr;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_items, in_a_assignStr)
    local
      Tpl.Text txt;
      list<TplAbsyn.MMExp> rest;
      String a_assignStr;
      TplAbsyn.MMExp i_it;

    case ( txt,
           {},
           _ )
      then txt;

    case ( txt,
           i_it :: rest,
           a_assignStr )
      equation
        txt = mmExp(txt, i_it, a_assignStr);
        txt = Tpl.nextIter(txt);
        txt = lm_35(txt, rest, a_assignStr);
      then txt;

    case ( txt,
           _ :: rest,
           a_assignStr )
      equation
        txt = lm_35(txt, rest, a_assignStr);
      then txt;
  end matchcontinue;
end lm_35;

public function mmExp
  input Tpl.Text in_txt;
  input TplAbsyn.MMExp in_a_it;
  input String in_a_assignStr;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_a_it, in_a_assignStr)
    local
      Tpl.Text txt;
      String a_assignStr;
      String i_value_1;
      TplAbsyn.StringToken i_value;
      TplAbsyn.PathIdent i_ident;
      list<TplAbsyn.MMExp> i_args;
      TplAbsyn.PathIdent i_fnName;
      TplAbsyn.MMExp i_rhs;
      list<TplAbsyn.Ident> i_lhsArgs;

    case ( txt,
           TplAbsyn.MM_ASSIGN(lhsArgs = i_lhsArgs, rhs = i_rhs),
           a_assignStr )
      equation
        txt = fun_34(txt, i_lhsArgs);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(" "));
        txt = Tpl.writeStr(txt, a_assignStr);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(" "));
        txt = mmExp(txt, i_rhs, a_assignStr);
      then txt;

    case ( txt,
           TplAbsyn.MM_FN_CALL(fnName = i_fnName, args = i_args),
           a_assignStr )
      equation
        txt = pathIdent(txt, i_fnName);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("("));
        txt = Tpl.pushIter(txt, Tpl.ITER_OPTIONS(0, NONE(), SOME(Tpl.ST_STRING(", ")), 0, 0, Tpl.ST_NEW_LINE(), 0, Tpl.ST_NEW_LINE()));
        txt = lm_35(txt, i_args, a_assignStr);
        txt = Tpl.popIter(txt);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(")"));
      then txt;

    case ( txt,
           TplAbsyn.MM_IDENT(ident = i_ident),
           _ )
      equation
        txt = pathIdent(txt, i_ident);
      then txt;

    case ( txt,
           TplAbsyn.MM_STR_TOKEN(value = i_value),
           _ )
      equation
        txt = mmStringTokenConstant(txt, i_value);
      then txt;

    case ( txt,
           TplAbsyn.MM_STRING(value = i_value_1),
           _ )
      equation
        txt = Tpl.pushBlock(txt, Tpl.BT_ABS_INDENT(0));
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("\""));
        txt = mmEscapeStringConst(txt, i_value_1, false);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("\""));
        txt = Tpl.popBlock(txt);
      then txt;

    case ( txt,
           TplAbsyn.MM_LITERAL(value = i_value_1),
           _ )
      equation
        txt = Tpl.writeStr(txt, i_value_1);
      then txt;

    case ( txt,
           _,
           _ )
      then txt;
  end matchcontinue;
end mmExp;

protected function lm_37
  input Tpl.Text in_txt;
  input list<tuple<TplAbsyn.Ident, TplAbsyn.MatchingExp>> in_items;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_items)
    local
      Tpl.Text txt;
      list<tuple<TplAbsyn.Ident, TplAbsyn.MatchingExp>> rest;
      TplAbsyn.MatchingExp i_mexp;
      TplAbsyn.Ident i_field;

    case ( txt,
           {} )
      then txt;

    case ( txt,
           (i_field, i_mexp) :: rest )
      equation
        txt = Tpl.writeStr(txt, i_field);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(" = "));
        txt = mmMatchingExp(txt, i_mexp);
        txt = Tpl.nextIter(txt);
        txt = lm_37(txt, rest);
      then txt;

    case ( txt,
           _ :: rest )
      equation
        txt = lm_37(txt, rest);
      then txt;
  end matchcontinue;
end lm_37;

protected function lm_38
  input Tpl.Text in_txt;
  input list<TplAbsyn.MatchingExp> in_items;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_items)
    local
      Tpl.Text txt;
      list<TplAbsyn.MatchingExp> rest;
      TplAbsyn.MatchingExp i_it;

    case ( txt,
           {} )
      then txt;

    case ( txt,
           i_it :: rest )
      equation
        txt = mmMatchingExp(txt, i_it);
        txt = Tpl.nextIter(txt);
        txt = lm_38(txt, rest);
      then txt;

    case ( txt,
           _ :: rest )
      equation
        txt = lm_38(txt, rest);
      then txt;
  end matchcontinue;
end lm_38;

protected function lm_39
  input Tpl.Text in_txt;
  input list<TplAbsyn.MatchingExp> in_items;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_items)
    local
      Tpl.Text txt;
      list<TplAbsyn.MatchingExp> rest;
      TplAbsyn.MatchingExp i_it;

    case ( txt,
           {} )
      then txt;

    case ( txt,
           i_it :: rest )
      equation
        txt = mmMatchingExp(txt, i_it);
        txt = Tpl.nextIter(txt);
        txt = lm_39(txt, rest);
      then txt;

    case ( txt,
           _ :: rest )
      equation
        txt = lm_39(txt, rest);
      then txt;
  end matchcontinue;
end lm_39;

public function mmMatchingExp
  input Tpl.Text in_txt;
  input TplAbsyn.MatchingExp in_a_it;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_a_it)
    local
      Tpl.Text txt;
      String i_value_1;
      TplAbsyn.MatchingExp i_rest;
      TplAbsyn.MatchingExp i_head;
      list<TplAbsyn.MatchingExp> i_listElts;
      list<TplAbsyn.MatchingExp> i_tupleArgs;
      TplAbsyn.MatchingExp i_value;
      list<tuple<TplAbsyn.Ident, TplAbsyn.MatchingExp>> i_fieldMatchings;
      TplAbsyn.PathIdent i_tagName;
      TplAbsyn.MatchingExp i_matchingExp;
      TplAbsyn.Ident i_bindIdent;

    case ( txt,
           TplAbsyn.BIND_AS_MATCH(bindIdent = i_bindIdent, matchingExp = i_matchingExp) )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("("));
        txt = Tpl.writeStr(txt, i_bindIdent);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(" as "));
        txt = mmMatchingExp(txt, i_matchingExp);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(")"));
      then txt;

    case ( txt,
           TplAbsyn.BIND_MATCH(bindIdent = i_bindIdent) )
      equation
        txt = Tpl.writeStr(txt, i_bindIdent);
      then txt;

    case ( txt,
           TplAbsyn.RECORD_MATCH(tagName = i_tagName, fieldMatchings = i_fieldMatchings) )
      equation
        txt = pathIdent(txt, i_tagName);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("("));
        txt = Tpl.pushIter(txt, Tpl.ITER_OPTIONS(0, NONE(), SOME(Tpl.ST_STRING(", ")), 0, 0, Tpl.ST_NEW_LINE(), 0, Tpl.ST_NEW_LINE()));
        txt = lm_37(txt, i_fieldMatchings);
        txt = Tpl.popIter(txt);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(")"));
      then txt;

    case ( txt,
           TplAbsyn.SOME_MATCH(value = i_value) )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("SOME("));
        txt = mmMatchingExp(txt, i_value);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(")"));
      then txt;

    case ( txt,
           TplAbsyn.NONE_MATCH() )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("NONE()"));
      then txt;

    case ( txt,
           TplAbsyn.TUPLE_MATCH(tupleArgs = i_tupleArgs) )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("("));
        txt = Tpl.pushIter(txt, Tpl.ITER_OPTIONS(0, NONE(), SOME(Tpl.ST_STRING(", ")), 0, 0, Tpl.ST_NEW_LINE(), 0, Tpl.ST_NEW_LINE()));
        txt = lm_38(txt, i_tupleArgs);
        txt = Tpl.popIter(txt);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(")"));
      then txt;

    case ( txt,
           TplAbsyn.LIST_MATCH(listElts = i_listElts) )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("{"));
        txt = Tpl.pushIter(txt, Tpl.ITER_OPTIONS(0, NONE(), SOME(Tpl.ST_STRING(", ")), 0, 0, Tpl.ST_NEW_LINE(), 0, Tpl.ST_NEW_LINE()));
        txt = lm_39(txt, i_listElts);
        txt = Tpl.popIter(txt);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("}"));
      then txt;

    case ( txt,
           TplAbsyn.LIST_CONS_MATCH(head = i_head, rest = i_rest) )
      equation
        txt = mmMatchingExp(txt, i_head);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(" :: "));
        txt = mmMatchingExp(txt, i_rest);
      then txt;

    case ( txt,
           TplAbsyn.STRING_MATCH(value = i_value_1) )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("\""));
        txt = mmEscapeStringConst(txt, i_value_1, true);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("\""));
      then txt;

    case ( txt,
           TplAbsyn.LITERAL_MATCH(value = i_value_1) )
      equation
        txt = Tpl.writeStr(txt, i_value_1);
      then txt;

    case ( txt,
           TplAbsyn.REST_MATCH() )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("_"));
      then txt;

    case ( txt,
           _ )
      then txt;
  end matchcontinue;
end mmMatchingExp;

protected function lm_41
  input Tpl.Text in_txt;
  input list<TplAbsyn.MMExp> in_items;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_items)
    local
      Tpl.Text txt;
      list<TplAbsyn.MMExp> rest;
      TplAbsyn.MMExp i_it;

    case ( txt,
           {} )
      then txt;

    case ( txt,
           i_it :: rest )
      equation
        txt = mmExp(txt, i_it, "=");
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(";"));
        txt = Tpl.nextIter(txt);
        txt = lm_41(txt, rest);
      then txt;

    case ( txt,
           _ :: rest )
      equation
        txt = lm_41(txt, rest);
      then txt;
  end matchcontinue;
end lm_41;

public function mmStatements
  input Tpl.Text txt;
  input list<TplAbsyn.MMExp> a_stmts;

  output Tpl.Text out_txt;
algorithm
  out_txt := Tpl.pushIter(txt, Tpl.ITER_OPTIONS(0, NONE(), SOME(Tpl.ST_NEW_LINE()), 0, 0, Tpl.ST_NEW_LINE(), 0, Tpl.ST_NEW_LINE()));
  out_txt := lm_41(out_txt, a_stmts);
  out_txt := Tpl.popIter(out_txt);
end mmStatements;

protected function fun_43
  input Tpl.Text in_txt;
  input Boolean in_a_isDefault;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_a_isDefault)
    local
      Tpl.Text txt;

    case ( txt,
           false )
      then txt;

    case ( txt,
           _ )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("default "));
      then txt;
  end matchcontinue;
end fun_43;

protected function lm_44
  input Tpl.Text in_txt;
  input list<tuple<TplAbsyn.Ident, TplAbsyn.TypeInfo>> in_items;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_items)
    local
      Tpl.Text txt;
      list<tuple<TplAbsyn.Ident, TplAbsyn.TypeInfo>> rest;
      TplAbsyn.TypeInfo i_tinfo;
      TplAbsyn.Ident i_id;

    case ( txt,
           {} )
      then txt;

    case ( txt,
           (i_id, i_tinfo) :: rest )
      equation
        txt = sASTDefType(txt, i_id, i_tinfo);
        txt = Tpl.nextIter(txt);
        txt = lm_44(txt, rest);
      then txt;

    case ( txt,
           _ :: rest )
      equation
        txt = lm_44(txt, rest);
      then txt;
  end matchcontinue;
end lm_44;

protected function lm_45
  input Tpl.Text in_txt;
  input list<TplAbsyn.ASTDef> in_items;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_items)
    local
      Tpl.Text txt;
      list<TplAbsyn.ASTDef> rest;
      list<tuple<TplAbsyn.Ident, TplAbsyn.TypeInfo>> i_types;
      TplAbsyn.PathIdent i_importPackage;
      Boolean i_isDefault;

    case ( txt,
           {} )
      then txt;

    case ( txt,
           TplAbsyn.AST_DEF(isDefault = i_isDefault, importPackage = i_importPackage, types = i_types) :: rest )
      equation
        txt = fun_43(txt, i_isDefault);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("absyn "));
        txt = pathIdent(txt, i_importPackage);
        txt = Tpl.softNewLine(txt);
        txt = Tpl.pushBlock(txt, Tpl.BT_INDENT(2));
        txt = Tpl.pushIter(txt, Tpl.ITER_OPTIONS(0, NONE(), SOME(Tpl.ST_STRING_LIST({
                                                                     "\n",
                                                                     "\n"
                                                                 }, true)), 0, 0, Tpl.ST_NEW_LINE(), 0, Tpl.ST_NEW_LINE()));
        txt = lm_44(txt, i_types);
        txt = Tpl.popIter(txt);
        txt = Tpl.softNewLine(txt);
        txt = Tpl.popBlock(txt);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("end "));
        txt = pathIdent(txt, i_importPackage);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(";"));
        txt = Tpl.writeTok(txt, Tpl.ST_NEW_LINE());
        txt = Tpl.nextIter(txt);
        txt = lm_45(txt, rest);
      then txt;

    case ( txt,
           _ :: rest )
      equation
        txt = lm_45(txt, rest);
      then txt;
  end matchcontinue;
end lm_45;

protected function lm_46
  input Tpl.Text in_txt;
  input list<tuple<TplAbsyn.Ident, TplAbsyn.TemplateDef>> in_items;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_items)
    local
      Tpl.Text txt;
      list<tuple<TplAbsyn.Ident, TplAbsyn.TemplateDef>> rest;
      TplAbsyn.Ident i_id;
      TplAbsyn.TemplateDef i_def;

    case ( txt,
           {} )
      then txt;

    case ( txt,
           (i_id, i_def) :: rest )
      equation
        txt = sTemplateDef(txt, i_def, i_id);
        txt = Tpl.nextIter(txt);
        txt = lm_46(txt, rest);
      then txt;

    case ( txt,
           _ :: rest )
      equation
        txt = lm_46(txt, rest);
      then txt;
  end matchcontinue;
end lm_46;

public function sTemplPackage
  input Tpl.Text in_txt;
  input TplAbsyn.TemplPackage in_a_it;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_a_it)
    local
      Tpl.Text txt;
      list<tuple<TplAbsyn.Ident, TplAbsyn.TemplateDef>> i_templateDefs;
      list<TplAbsyn.ASTDef> i_astDefs;
      TplAbsyn.PathIdent i_name;

    case ( txt,
           TplAbsyn.TEMPL_PACKAGE(name = i_name, astDefs = i_astDefs, templateDefs = i_templateDefs) )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("spackage "));
        txt = pathIdent(txt, i_name);
        txt = Tpl.softNewLine(txt);
        txt = Tpl.pushBlock(txt, Tpl.BT_INDENT(2));
        txt = Tpl.pushIter(txt, Tpl.ITER_OPTIONS(0, NONE(), SOME(Tpl.ST_NEW_LINE()), 0, 0, Tpl.ST_NEW_LINE(), 0, Tpl.ST_NEW_LINE()));
        txt = lm_45(txt, i_astDefs);
        txt = Tpl.popIter(txt);
        txt = Tpl.softNewLine(txt);
        txt = Tpl.writeTok(txt, Tpl.ST_NEW_LINE());
        txt = Tpl.popBlock(txt);
        txt = Tpl.pushIter(txt, Tpl.ITER_OPTIONS(0, NONE(), SOME(Tpl.ST_STRING_LIST({
                                                                     "\n",
                                                                     "\n"
                                                                 }, true)), 0, 0, Tpl.ST_NEW_LINE(), 0, Tpl.ST_NEW_LINE()));
        txt = lm_46(txt, i_templateDefs);
        txt = Tpl.popIter(txt);
        txt = Tpl.softNewLine(txt);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("end "));
        txt = pathIdent(txt, i_name);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(";"));
      then txt;

    case ( txt,
           _ )
      then txt;
  end matchcontinue;
end sTemplPackage;

protected function lm_48
  input Tpl.Text in_txt;
  input list<tuple<TplAbsyn.Ident, TplAbsyn.TypedIdents>> in_items;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_items)
    local
      Tpl.Text txt;
      list<tuple<TplAbsyn.Ident, TplAbsyn.TypedIdents>> rest;
      TplAbsyn.TypedIdents i_tids;
      TplAbsyn.Ident i_rid;

    case ( txt,
           {} )
      then txt;

    case ( txt,
           (i_rid, i_tids) :: rest )
      equation
        txt = sRecordTypeDef(txt, i_rid, i_tids);
        txt = Tpl.nextIter(txt);
        txt = lm_48(txt, rest);
      then txt;

    case ( txt,
           _ :: rest )
      equation
        txt = lm_48(txt, rest);
      then txt;
  end matchcontinue;
end lm_48;

protected function lm_49
  input Tpl.Text in_txt;
  input TplAbsyn.TypedIdents in_items;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_items)
    local
      Tpl.Text txt;
      TplAbsyn.TypedIdents rest;
      TplAbsyn.Ident i_aid;
      TplAbsyn.TypeSignature i_ts;

    case ( txt,
           {} )
      then txt;

    case ( txt,
           (i_aid, i_ts) :: rest )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("input "));
        txt = typeSig(txt, i_ts);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(" "));
        txt = Tpl.writeStr(txt, i_aid);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(";"));
        txt = Tpl.writeTok(txt, Tpl.ST_NEW_LINE());
        txt = lm_49(txt, rest);
      then txt;

    case ( txt,
           _ :: rest )
      equation
        txt = lm_49(txt, rest);
      then txt;
  end matchcontinue;
end lm_49;

protected function lm_50
  input Tpl.Text in_txt;
  input TplAbsyn.TypedIdents in_items;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_items)
    local
      Tpl.Text txt;
      TplAbsyn.TypedIdents rest;
      TplAbsyn.Ident i_aid;
      TplAbsyn.TypeSignature i_ts;

    case ( txt,
           {} )
      then txt;

    case ( txt,
           (i_aid, i_ts) :: rest )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("output "));
        txt = typeSig(txt, i_ts);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(" "));
        txt = Tpl.writeStr(txt, i_aid);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(";"));
        txt = Tpl.writeTok(txt, Tpl.ST_NEW_LINE());
        txt = lm_50(txt, rest);
      then txt;

    case ( txt,
           _ :: rest )
      equation
        txt = lm_50(txt, rest);
      then txt;
  end matchcontinue;
end lm_50;

protected function fun_51
  input Tpl.Text in_txt;
  input TplAbsyn.TypeInfo in_a_info;
  input TplAbsyn.Ident in_a_id;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_a_info, in_a_id)
    local
      Tpl.Text txt;
      TplAbsyn.Ident a_id;
      TplAbsyn.TypeSignature i_constType;
      TplAbsyn.TypedIdents i_outArgs;
      TplAbsyn.TypedIdents i_inArgs;
      TplAbsyn.TypeSignature i_aliasType;
      TplAbsyn.TypedIdents i_fields;
      list<tuple<TplAbsyn.Ident, TplAbsyn.TypedIdents>> i_recTags;

    case ( txt,
           TplAbsyn.TI_UNION_TYPE(recTags = i_recTags),
           a_id )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("uniontype "));
        txt = Tpl.writeStr(txt, a_id);
        txt = Tpl.softNewLine(txt);
        txt = Tpl.pushBlock(txt, Tpl.BT_INDENT(2));
        txt = Tpl.pushIter(txt, Tpl.ITER_OPTIONS(0, NONE(), SOME(Tpl.ST_NEW_LINE()), 0, 0, Tpl.ST_NEW_LINE(), 0, Tpl.ST_NEW_LINE()));
        txt = lm_48(txt, i_recTags);
        txt = Tpl.popIter(txt);
        txt = Tpl.softNewLine(txt);
        txt = Tpl.popBlock(txt);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("end "));
        txt = Tpl.writeStr(txt, a_id);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(";"));
      then txt;

    case ( txt,
           TplAbsyn.TI_RECORD_TYPE(fields = i_fields),
           a_id )
      equation
        txt = sRecordTypeDef(txt, a_id, i_fields);
      then txt;

    case ( txt,
           TplAbsyn.TI_ALIAS_TYPE(aliasType = i_aliasType),
           a_id )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("type "));
        txt = Tpl.writeStr(txt, a_id);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(" = "));
        txt = typeSig(txt, i_aliasType);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(";"));
      then txt;

    case ( txt,
           TplAbsyn.TI_FUN_TYPE(inArgs = i_inArgs, outArgs = i_outArgs),
           a_id )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("function "));
        txt = Tpl.writeStr(txt, a_id);
        txt = Tpl.softNewLine(txt);
        txt = Tpl.pushBlock(txt, Tpl.BT_INDENT(2));
        txt = lm_49(txt, i_inArgs);
        txt = Tpl.softNewLine(txt);
        txt = lm_50(txt, i_outArgs);
        txt = Tpl.softNewLine(txt);
        txt = Tpl.popBlock(txt);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("end "));
        txt = Tpl.writeStr(txt, a_id);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(";"));
      then txt;

    case ( txt,
           TplAbsyn.TI_CONST_TYPE(constType = i_constType),
           a_id )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("constant "));
        txt = typeSig(txt, i_constType);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(" "));
        txt = Tpl.writeStr(txt, a_id);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(";"));
      then txt;

    case ( txt,
           _,
           _ )
      then txt;
  end matchcontinue;
end fun_51;

public function sASTDefType
  input Tpl.Text txt;
  input TplAbsyn.Ident a_id;
  input TplAbsyn.TypeInfo a_info;

  output Tpl.Text out_txt;
algorithm
  out_txt := fun_51(txt, a_info, a_id);
end sASTDefType;

protected function lm_53
  input Tpl.Text in_txt;
  input TplAbsyn.TypedIdents in_items;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_items)
    local
      Tpl.Text txt;
      TplAbsyn.TypedIdents rest;
      TplAbsyn.Ident i_fid;
      TplAbsyn.TypeSignature i_ts;

    case ( txt,
           {} )
      then txt;

    case ( txt,
           (i_fid, i_ts) :: rest )
      equation
        txt = typeSig(txt, i_ts);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(" "));
        txt = Tpl.writeStr(txt, i_fid);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(";"));
        txt = Tpl.writeTok(txt, Tpl.ST_NEW_LINE());
        txt = lm_53(txt, rest);
      then txt;

    case ( txt,
           _ :: rest )
      equation
        txt = lm_53(txt, rest);
      then txt;
  end matchcontinue;
end lm_53;

protected function fun_54
  input Tpl.Text in_txt;
  input TplAbsyn.TypedIdents in_a_fields;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_a_fields)
    local
      Tpl.Text txt;
      TplAbsyn.TypedIdents i_fields;

    case ( txt,
           {} )
      then txt;

    case ( txt,
           i_fields )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_NEW_LINE());
        txt = Tpl.pushBlock(txt, Tpl.BT_INDENT(2));
        txt = lm_53(txt, i_fields);
        txt = Tpl.popBlock(txt);
      then txt;
  end matchcontinue;
end fun_54;

public function sRecordTypeDef
  input Tpl.Text txt;
  input TplAbsyn.Ident a_id;
  input TplAbsyn.TypedIdents a_fields;

  output Tpl.Text out_txt;
algorithm
  out_txt := Tpl.writeTok(txt, Tpl.ST_STRING("record "));
  out_txt := Tpl.writeStr(out_txt, a_id);
  out_txt := Tpl.writeTok(out_txt, Tpl.ST_STRING(" "));
  out_txt := fun_54(out_txt, a_fields);
  out_txt := Tpl.writeTok(out_txt, Tpl.ST_STRING("end "));
  out_txt := Tpl.writeStr(out_txt, a_id);
  out_txt := Tpl.writeTok(out_txt, Tpl.ST_STRING(";"));
end sRecordTypeDef;

public function sTemplateDef
  input Tpl.Text in_txt;
  input TplAbsyn.TemplateDef in_a_it;
  input TplAbsyn.Ident in_a_templId;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_a_it, in_a_templId)
    local
      Tpl.Text txt;
      TplAbsyn.Ident a_templId;
      TplAbsyn.StringToken i_value;

    case ( txt,
           TplAbsyn.STR_TOKEN_DEF(value = i_value),
           a_templId )
      equation
        txt = Tpl.writeStr(txt, a_templId);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(" = "));
        txt = sConstStringToken(txt, i_value);
      then txt;

    case ( txt,
           _,
           _ )
      then txt;
  end matchcontinue;
end sTemplateDef;

protected function lm_57
  input Tpl.Text in_txt;
  input list<String> in_items;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_items)
    local
      Tpl.Text txt;
      list<String> rest;
      String i_it;

    case ( txt,
           {} )
      then txt;

    case ( txt,
           i_it :: rest )
      equation
        txt = mmEscapeStringConst(txt, i_it, false);
        txt = lm_57(txt, rest);
      then txt;

    case ( txt,
           _ :: rest )
      equation
        txt = lm_57(txt, rest);
      then txt;
  end matchcontinue;
end lm_57;

protected function lm_58
  input Tpl.Text in_txt;
  input list<String> in_items;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_items)
    local
      Tpl.Text txt;
      list<String> rest;
      String i_it;

    case ( txt,
           {} )
      then txt;

    case ( txt,
           i_it :: rest )
      equation
        txt = mmEscapeStringConst(txt, i_it, true);
        txt = lm_58(txt, rest);
      then txt;

    case ( txt,
           _ :: rest )
      equation
        txt = lm_58(txt, rest);
      then txt;
  end matchcontinue;
end lm_58;

protected function lm_59
  input Tpl.Text in_txt;
  input list<String> in_items;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_items)
    local
      Tpl.Text txt;
      list<String> rest;
      String i_it;

    case ( txt,
           {} )
      then txt;

    case ( txt,
           i_it :: rest )
      equation
        txt = mmEscapeStringConst(txt, i_it, true);
        txt = lm_59(txt, rest);
      then txt;

    case ( txt,
           _ :: rest )
      equation
        txt = lm_59(txt, rest);
      then txt;
  end matchcontinue;
end lm_59;

protected function fun_60
  input Tpl.Text in_txt;
  input Boolean in_mArg;
  input list<String> in_a_sl;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_mArg, in_a_sl)
    local
      Tpl.Text txt;
      list<String> a_sl;

    case ( txt,
           false,
           a_sl )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("\""));
        txt = lm_58(txt, a_sl);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("\""));
      then txt;

    case ( txt,
           _,
           a_sl )
      equation
        txt = lm_59(txt, a_sl);
      then txt;
  end matchcontinue;
end fun_60;

protected function fun_61
  input Tpl.Text in_txt;
  input Boolean in_mArg;
  input list<String> in_a_sl;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_mArg, in_a_sl)
    local
      Tpl.Text txt;
      list<String> a_sl;
      Boolean ret_0;

    case ( txt,
           false,
           a_sl )
      equation
        txt = Tpl.pushBlock(txt, Tpl.BT_ABS_INDENT(0));
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("\""));
        txt = lm_57(txt, a_sl);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("\""));
        txt = Tpl.popBlock(txt);
      then txt;

    case ( txt,
           _,
           a_sl )
      equation
        ret_0 = TplAbsyn.canBeEscapedUnquoted(a_sl);
        txt = fun_60(txt, ret_0, a_sl);
      then txt;
  end matchcontinue;
end fun_61;

public function sConstStringToken
  input Tpl.Text in_txt;
  input Tpl.StringToken in_a_it;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_a_it)
    local
      Tpl.Text txt;
      list<String> i_sl;
      String i_line;
      String i_value;
      Boolean ret_0;

    case ( txt,
           Tpl.ST_NEW_LINE() )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("\\n"));
      then txt;

    case ( txt,
           Tpl.ST_STRING(value = i_value) )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("\""));
        txt = mmEscapeStringConst(txt, i_value, true);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("\""));
      then txt;

    case ( txt,
           Tpl.ST_LINE(line = i_line) )
      equation
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("\""));
        txt = mmEscapeStringConst(txt, i_line, true);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING("\""));
      then txt;

    case ( txt,
           Tpl.ST_STRING_LIST(strList = i_sl) )
      equation
        ret_0 = TplAbsyn.canBeOnOneLine(i_sl);
        txt = fun_61(txt, ret_0, i_sl);
      then txt;

    case ( txt,
           _ )
      then txt;
  end matchcontinue;
end sConstStringToken;

protected function lm_63
  input Tpl.Text in_txt;
  input TplAbsyn.TypedIdents in_items;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_items)
    local
      Tpl.Text txt;
      TplAbsyn.TypedIdents rest;
      TplAbsyn.Ident i_fid;
      TplAbsyn.TypeSignature i_ts;

    case ( txt,
           {} )
      then txt;

    case ( txt,
           (i_fid, i_ts) :: rest )
      equation
        txt = typeSig(txt, i_ts);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(" "));
        txt = Tpl.writeStr(txt, i_fid);
        txt = Tpl.nextIter(txt);
        txt = lm_63(txt, rest);
      then txt;

    case ( txt,
           _ :: rest )
      equation
        txt = lm_63(txt, rest);
      then txt;
  end matchcontinue;
end lm_63;

public function sTypedIdents
  input Tpl.Text txt;
  input TplAbsyn.TypedIdents a_args;

  output Tpl.Text out_txt;
algorithm
  out_txt := Tpl.pushIter(txt, Tpl.ITER_OPTIONS(0, NONE(), SOME(Tpl.ST_STRING(", ")), 0, 0, Tpl.ST_NEW_LINE(), 0, Tpl.ST_NEW_LINE()));
  out_txt := lm_63(out_txt, a_args);
  out_txt := Tpl.popIter(out_txt);
end sTypedIdents;

public function sFunSignature
  input Tpl.Text txt;
  input TplAbsyn.PathIdent a_name;
  input TplAbsyn.TypedIdents a_iargs;
  input TplAbsyn.TypedIdents a_oargs;

  output Tpl.Text out_txt;
algorithm
  out_txt := pathIdent(txt, a_name);
  out_txt := Tpl.writeTok(out_txt, Tpl.ST_STRING("("));
  out_txt := sTypedIdents(out_txt, a_iargs);
  out_txt := Tpl.writeTok(out_txt, Tpl.ST_STRING(") -> ("));
  out_txt := sTypedIdents(out_txt, a_oargs);
  out_txt := Tpl.writeTok(out_txt, Tpl.ST_STRING(")"));
end sFunSignature;

protected function lm_66
  input Tpl.Text in_txt;
  input list<tuple<TplAbsyn.MMExp, TplAbsyn.TypeSignature>> in_items;

  output Tpl.Text out_txt;
algorithm
  out_txt :=
  matchcontinue(in_txt, in_items)
    local
      Tpl.Text txt;
      list<tuple<TplAbsyn.MMExp, TplAbsyn.TypeSignature>> rest;
      TplAbsyn.MMExp i_mexp;
      TplAbsyn.TypeSignature i_ts;

    case ( txt,
           {} )
      then txt;

    case ( txt,
           (i_mexp, i_ts) :: rest )
      equation
        txt = typeSig(txt, i_ts);
        txt = Tpl.writeTok(txt, Tpl.ST_STRING(" "));
        txt = mmExp(txt, i_mexp, "=");
        txt = Tpl.nextIter(txt);
        txt = lm_66(txt, rest);
      then txt;

    case ( txt,
           _ :: rest )
      equation
        txt = lm_66(txt, rest);
      then txt;
  end matchcontinue;
end lm_66;

public function sActualMMParams
  input Tpl.Text txt;
  input list<tuple<TplAbsyn.MMExp, TplAbsyn.TypeSignature>> a_argValues;

  output Tpl.Text out_txt;
algorithm
  out_txt := Tpl.writeTok(txt, Tpl.ST_STRING("("));
  out_txt := Tpl.pushIter(out_txt, Tpl.ITER_OPTIONS(0, NONE(), SOME(Tpl.ST_STRING(", ")), 0, 0, Tpl.ST_NEW_LINE(), 0, Tpl.ST_NEW_LINE()));
  out_txt := lm_66(out_txt, a_argValues);
  out_txt := Tpl.popIter(out_txt);
  out_txt := Tpl.writeTok(out_txt, Tpl.ST_STRING(")"));
end sActualMMParams;

end TplCodegen;
