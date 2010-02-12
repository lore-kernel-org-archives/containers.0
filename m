From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [cr_tests] warning fixes and build system changes
Date: Fri, 12 Feb 2010 08:25:39 -0600
Message-ID: <20100212142539.GB9653@us.ibm.com>
References: <1265930227.17626.3313.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1265930227.17626.3313.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Nathan Lynch (ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org):
> Hi all,
> 
> Serge has kindly pulled a pile of -Wall fixes and Makefile changes into
> the "ntl" branch at git://git.sr71.net/~hallyn/cr_tests.git.  The
> motivation behind this is that building the testsuite with a non-default
> word size (e.g. 64-bit on most powerpc distributions) is basically
> impossible with the current set of Makefiles, some of which use CFLAGS
> improperly or hard-code "gcc".  With the changes in this branch, "make
> CFLAGS=-m64" does the right thing, and the test suite builds cleanly
> with -Wall and both 32- and 64-bit output.
> 
> Patch summaries and overall diffstat below.  Please follow up here with
> any concerns, thanks!

Mostly compiled and ran fine on my end so I expect to push it to master
branch today.  The two problems I had resulted from an old userspace.

Thanks for cleaning this up.

-serge

> Nathan Lynch (29):
>   cr_tests/eclone: add USER_CR_DIR to linker search path
>   cr_tests/libcrtest: add declaration for print_exit_status
>   cr_tests/libcrtest: make u64 unsigned long long
>   cr_tests/libfutex: include local header with quotes, not brackets
>   cr_tests/nsexec: fix -Wall warnings
>   cr_tests/libcrtest: fix -Wall warnings etc
>   cr_tests/eclone: fix -Wall warnings
>   cr_tests/fileio1: fix -Wall warnings
>   cr_tests/filelock1: fix -Wall warnings
>   cr_tests/filelock2: fix -Wall warnings
>   cr_tests/fsetown1: fix -Wall warnings
>   cr_tests/filelease1: fix -Wall warnings
>   cr_tests/filelease2: fix -Wall warnings
>   cr_tests/ptree1: fix -Wall warnings etc
>   cr_tests/pthread1: fix -Wall warnings
>   cr_tests/pthread2: fix -Wall warnings
>   cr_tests/pthread3: fix -Wall warnings
>   cr_tests/pthread4: fix -Wall warnings
>   cr_tests/create-sem: fix -Wall warnings
>   cr_tests/check-mq: include libcrtest.h
>   cr_tests/chrootsleep: fix -Wall warnings
>   cr_tests/userns_ckptme: fix -Wall warnings
>   cr_tests/usertask: fix -Wall warnings
>   cr_tests/userns_deep: fix -Wall warnings
>   cr_tests/simple_deep: fix -Wall warnings
>   cr_tests/epoll: strlen returns size_t
>   cr_tests/pthread: use correct size_t printf conversion
>   cr_tests: rework build system
>   cr_tests: remove old Makefiles
> 
>  Makefile                  |   50 +++++++++++++++++++++++++++++++----------
>  bashckpt/module.mk        |    3 ++
>  counterloop/Makefile      |    7 -----
>  counterloop/module.mk     |    5 ++++
>  eclone/Makefile           |   21 -----------------
>  eclone/eclone-1.c         |    8 +++---
>  eclone/eclone-2.c         |    8 +++---
>  eclone/eclone-3.c         |    8 +++---
>  eclone/eclone-4.c         |    8 +++---
>  eclone/eclone-5.c         |    8 +++---
>  eclone/module.mk          |    9 +++++++
>  epoll/Makefile            |   29 ------------------------
>  epoll/cycle.c             |    4 +-
>  epoll/module.mk           |   11 +++++++++
>  epoll/pipe.c              |    4 +-
>  epoll/scm.c               |    4 +-
>  epoll/sk10k.c             |    4 +-
>  fileio/Makefile           |   12 ----------
>  fileio/fileio1.c          |    3 ++
>  fileio/filelease1.c       |    9 +++++--
>  fileio/filelease2.c       |   19 ++++++++++-----
>  fileio/filelock1.c        |   16 ++++++++-----
>  fileio/filelock2.c        |   29 +++++++++---------------
>  fileio/fsetown1.c         |   16 ++++++------
>  fileio/module.mk          |   12 ++++++++++
>  futex/Makefile            |   44 ------------------------------------
>  futex/libfutex/Makefile   |   16 -------------
>  futex/libfutex/libfutex.h |    2 +-
>  futex/libfutex/module.mk  |   11 +++++++++
>  futex/module.mk           |   15 ++++++++++++
>  ipc/Makefile              |   18 ---------------
>  ipc/check-mq.c            |    2 +
>  ipc/create-sem.c          |    5 +++-
>  ipc/module.mk             |   10 ++++++++
>  libcrtest/Makefile        |   11 ---------
>  libcrtest/common.c        |   16 ++++++++++---
>  libcrtest/libcrtest.h     |    4 +-
>  libcrtest/module.mk       |   11 +++++++++
>  ns_exec.c                 |    6 ++--
> 
