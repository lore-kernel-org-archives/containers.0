From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [mnt] 81e3bb1b6f:
	BUG:sleeping_function_called_from_invalid_context_at_fs/dcache.c
Date: Fri, 02 Dec 2016 21:05:22 -0600
Message-ID: <87r35pemq5.fsf@xmission.com>
References: <20161203022338.GA76683@inn.lkp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20161203022338.GA76683-aQzoWfPLU1itqXYlAKuG4QC/G2K4zDHf@public.gmane.org> (kernel test robot's
	message of "Sat, 3 Dec 2016 10:23:38 +0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: kernel test robot <xiaolong.ye-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lkp-JC7UmRfGjtg@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

kernel test robot <xiaolong.ye-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> writes:

> FYI, we noticed the following commit:
>
> commit: 81e3bb1b6f6d84d47e773f34a14b0955e528c6eb ("mnt: Tuck mounts under others instead of creating shadow/side mounts.")
> https://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-testing
>
> in testcase: boot
>
> on test machine: qemu-system-x86_64 -enable-kvm -cpu host -smp 2 -m 1G
>
> caused below changes:

Bah.  Obvious in hind site...

Thank you testing robot,

Eric
