From: Tejun Heo <tj@kernel.org>
Subject: [EXAMPLE CODE] Parasite thread injection using PTRACE_SEIZE and
 friends
Date: Wed, 20 Jul 2011 16:00:37 +0200
Message-ID: <20110720140037.GM3455@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="zYM0uCDKw75PZbzx"
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Pavel Emelyanov <xemul@parallels.com>, Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Serge Hallyn <serue@us.ibm.com>, Cyri
Cc: Linux Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org


--zYM0uCDKw75PZbzx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hello,

This has taken much longer than expected (which BTW is usually
expected) but ptrace fixes and new features are mostly complete now.
They're sitting in Oleg's ptrace branch waiting for merge window.

  http://git.kernel.org/?p=linux/kernel/git/oleg/misc.git;a=shortlog;h=refs/heads/ptrace
  git://git.kernel.org/pub/scm/linux/kernel/git/oleg/misc.git ptrace
 
With new ptrace requests, a process can be captured and manipulated
practically transparently.  Other than syscall retry or -EINTR failure
in special cases and timing difference, everything including job
control stop state stays transparent across ptrace operations.

One of the concerns raised about using ptrace for CR was that it
doesn't have access to states which are visible only to the process
being checkpointed and exporting every such information outside would
be too laborious.  The attached ptrace-parasite example code
demonstrates how this can be solved.  Using new ptrace requests, it
inserts a parasite thread to the host process transparently.  The code
is also available in the following git branch (the first link is code
brwser, second git branch you can clone from).

  http://code.google.com/p/ptrace-parasite/source/browse/
  https://code.google.com/p/ptrace-parasite/ ptrace-parasite

It only works on x86-64 and requires Oleg's ptrace branch.  'make'
produces two binaries - simple-host and parasite.  If you run
simple-host in a terminal and run parasite with the pid (thread 00's
tid) of the simple-host in another terminal, you should see something
like the following.

  # ./simple-host
  thread 01(4580): alive
  thread 02(4581): alive
  thread 03(4582): alive
  thread 04(4583): alive
  thread 00(4579): alive
  hello, world!
  parasite: hello, world!
  parasite: tid / time = 4629 / 1311169280
  thread 03(4582): alive
  thread 02(4581): alive
  thread 01(4580): alive
  thread 04(4583): alive
  thread 00(4579): alive
  ...

  # ./parasite 4579
  Seizing 4579
  Seizing 4580
  Seizing 4581
  Seizing 4582
  Seizing 4583
  executing test blob
  blocking all signals = 0, prev_sigmask 0
  executing mmap blob = 0x7fc4eca35000
  executing clone blob = 4629
  executing parasite
  executing munmap blob = 0
  restoring sigmask = 0, prev_sigmask 0xfffffffffffbfeef

The first "hello, world!" is printed by the infected host thread which
is then directed to block all signals, mmap an area and clone parasite
thread.  The lines which start with "parasite: " are printed by the
new parasite thread.  While the parasite is running, all host threads
are ptrace trapped and when they're resumed they have no way to find
out what happened to their precious process.  Note that host can be
any program.

The implementation is naive and simplicistic, especially the part
which seizes all threads belonging to the target process but it should
be enough to demonstrate how this can be done.

I'm sure there still are a lot of things missing for reasonable
userland CR but I think this should at least provide the core process
capturing part of it and make the whole thing more feasible.

One missing piece is that it can't operate on a process which is
already being ptraced.  Adding nested ptrace would solve some part of
it but it leads to a lot of complexity, most of it stemming from the
fact that it diversifies the places target processes may be trapped
at.  Determining which exact point isn't that difficult but rolling
back from and restoring to some of those debug traps can be difficult
or even impossible.  For debugger checkpointing, probably more
cooperative approach would make more sense.  Anyways, I don't think
this is too big a deal at this point.

Thank you.

--
tejun

--zYM0uCDKw75PZbzx
Content-Type: application/x-gzip
Content-Disposition: attachment; filename="ptrace-parasite.tar.gz"
Content-Transfer-Encoding: base64

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
nqnDqpRN+JHBMdQMbXzqwROMjI82PIqBM5qExk0TZ7SCOA9kLk2DvjkQehfpFWmthyAWR1C0
Zgb5BNrEGqeXeO+nKUdMjgqB61NGRQl6mDERk5p54oxWjy5Mmvha18QxzdhHMdRo/JsmXe5Z
c7knc5ppJ1j0N8bGHuYkBRLMajxOa+s17EbGPvlg5EbYxLVWC4FXO6v41dMNW2GGOP3RaKQn
T/D5hq0fQn3uxn1QysFWK4PEqiXsVJSn9zlgkh36Yju5tr7P8nd7vcbBgo5GsSOa13WGfMf6
JOUqP2ZJRUqY4gmnNgJOVl5PGSkztMALMvLJrjeaRHVykwNfRCqzAGJkQQzh5CDHK9ZZHCcg
24t4wDWuqm7ARMEP3SSfdRFO+lznc5CSb2voar6kHTr6Zy63yT08Wlp8Db+L7cIdxgu/bBpI
l5iO7MlFxq0VFWJykSIdq3yfEEaVBoT/gil+34FnqqxNJLRjPsNPv0S4nuKg2L7Pmet4HzCv
IcJg/HkklbeleK0/FxAh5h2dIE5Pm7J6oB1Mo7EaIzNuk71tWLO3jdI1K7pfn9pJ2HuNrBFK
zabeyNzBD/JIcFC8oVirLbgYjV2wYz+ogBD3cCRzK9pz18hK18QCP5DzTVv1P+6pLsvXKAv9
f9eOHmqMe/z/zsb2dsn/39rZXPr/f0I5v766uL4yfzi/fHl0pTX6jmeF84Zel/VHl89/0pzN
vZ392d5Oa2cLvN1e9zl9w4cKW2jQfeEuaBntposK+YiXAtq2FVspKL5JoNDPvPSjCJ/aYLKO
Tk9+PNPUedTHpQL5GqW4/3O/LfNAY9z3+0+7O6Xf/9rZxn8faPw7yz98/3/h73+Uf9FD/gjR
vT+PUfG7GulvddRzfry8ioFIooAPWBwZeK/4N9aOb0xwMeDZYB+LSQIZ+kPB6P+vjRpFyC84
Yw49md20whENTfc77HLuGtrvjE2SQM0QgZpneX7kch5oj5FF6WFfkq2W3wOvdDZsbWWq7zML
L2CRNy/TonougkMEpXkAiRa5daa8harJD97E3UF1Mx7C1KacOKzeTKRgJR0VFxK/FQnzBE3r
WXoHMZvfzcSIJBUJNSyyhFBElplWHpbJFUeGCCY+FjpkvSNT3qVCMapJEcZkcTxW92+yF0cS
lPih3nXv0qDbShV3xoqAGwXATJLdEEn27SRzrqgYwF8Iux4H+OsRIp2cCFJz0bVGh5CnAtd5
2GzxsizLsizLsizLsizLsizLsizLsizLsizLsizLsizLsizLsizLsizLsizLsizLsizLsvzd
yv8D8TmSOAB4AAA=

--zYM0uCDKw75PZbzx--
