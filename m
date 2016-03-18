From: kbuild test robot <lkp-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v2 2/3] Run dump pipe in container's namespace
Date: Fri, 18 Mar 2016 22:06:27 +0800
Message-ID: <201603182223.SzpIQC40%fengguang.wu@intel.com>
References: <a1ac975a165b63c8ee67f9785e50067be41a74ff.1458305141.git.zhaolei@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="BOKacYhQ+x31HxR3"
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <a1ac975a165b63c8ee67f9785e50067be41a74ff.1458305141.git.zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Zhao Lei <zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, kbuild-all-JC7UmRfGjtg@public.gmane.org
List-Id: containers.vger.kernel.org


--BOKacYhQ+x31HxR3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Zhao,

[auto build test ERROR on tip/sched/core]
[also build test ERROR on v4.5 next-20160318]
[if your patch is applied to the wrong git tree, please drop us a note to help improving the system]

url:    https://github.com/0day-ci/linux/commits/Zhao-Lei/Make-core_pattern-support-namespace/20160318-205506
config: um-x86_64_defconfig (attached as .config)
reproduce:
        # save the attached .config to linux build tree
        make ARCH=um SUBARCH=x86_64

All errors (new ones prefixed by >>):

   kernel/time/Kconfig:155:warning: range is invalid
   In file included from arch/x86/um/asm/elf.h:9:0,
                    from include/linux/elf.h:4,
                    from arch/x86/um/shared/sysdep/kernel-offsets.h:3,
                    from arch/um/kernel/asm-offsets.c:1:
>> arch/um/include/shared/skas/skas.h:13:12: error: conflicting types for 'user_thread'
    extern int user_thread(unsigned long stack, int flags);
               ^
   In file included from arch/x86/um/shared/sysdep/kernel-offsets.h:2:0,
                    from arch/um/kernel/asm-offsets.c:1:
   include/linux/sched.h:2652:14: note: previous declaration of 'user_thread' was here
    extern pid_t user_thread(int (*fn)(void *), void *arg, unsigned long flags);
                 ^
   make[2]: *** [arch/um/kernel/asm-offsets.s] Error 1
   make[2]: Target '__build' not remade because of errors.
   make[1]: *** [prepare0] Error 2
   make[1]: Target 'prepare' not remade because of errors.
   make: *** [sub-make] Error 2

vim +/user_thread +13 arch/um/include/shared/skas/skas.h

^1da177e4c arch/um/kernel/skas/include/skas.h Linus Torvalds 2005-04-16   7  #define __SKAS_H
^1da177e4c arch/um/kernel/skas/include/skas.h Linus Torvalds 2005-04-16   8  
37185b3324 arch/um/include/shared/skas/skas.h Al Viro        2012-10-08   9  #include <sysdep/ptrace.h>
^1da177e4c arch/um/kernel/skas/include/skas.h Linus Torvalds 2005-04-16  10  
^1da177e4c arch/um/kernel/skas/include/skas.h Linus Torvalds 2005-04-16  11  extern int userspace_pid[];
^1da177e4c arch/um/kernel/skas/include/skas.h Linus Torvalds 2005-04-16  12  
^1da177e4c arch/um/kernel/skas/include/skas.h Linus Torvalds 2005-04-16 @13  extern int user_thread(unsigned long stack, int flags);
3c91735099 arch/um/include/skas/skas.h        Jeff Dike      2006-09-27  14  extern void new_thread_handler(void);
77bf440031 arch/um/include/skas/skas.h        Jeff Dike      2007-10-16  15  extern void handle_syscall(struct uml_pt_regs *regs);
^1da177e4c arch/um/kernel/skas/include/skas.h Linus Torvalds 2005-04-16  16  extern long execute_syscall_skas(void *r);

:::::: The code at line 13 was first introduced by commit
:::::: 1da177e4c3f41524e886b7f1b8a0c1fc7321cac2 Linux-2.6.12-rc2

:::::: TO: Linus Torvalds <torvalds-gWtpgVMusWVb5UGfqNBoRg@public.gmane.org>
:::::: CC: Linus Torvalds <torvalds-gWtpgVMusWVb5UGfqNBoRg@public.gmane.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--BOKacYhQ+x31HxR3
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--BOKacYhQ+x31HxR3
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--BOKacYhQ+x31HxR3--
