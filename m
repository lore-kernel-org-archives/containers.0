From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH] x86_86 support of checkpoint/restart (Re:
	Checkpoint / Restart)
Date: Mon, 09 Feb 2009 10:02:38 -0800
Message-ID: <1234202558.20090.201.camel@nimitz>
References: <20090207001609.8168.14884.stgit@lahore.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090207001609.8168.14884.stgit-AP77eCFSSktSzHKm+aFRNNkmqwFzkYv6@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Ralph-Gordon.Paul-4bfl1RV3iZDOEhgYWvzSCYQuADTiUCJX@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, 2009-02-06 at 16:17 -0800, Nauman Rafique wrote:
> The patch sent by Masahiko assumes that all the user-space registers
> are saved on
> the kernel stack on a system call. This is not true for the majority
> of the system calls. The callee saved registers (as defined by x86_64
> ABI) - rbx, rbp, r12, r13, r14, r15 - are saved only in some special
> cases. That means that these registers would not be available to
> checkpoint code. Moreover, the restore code would have no space in
> stack to restore those registers.

According to this:

http://msdn.microsoft.com/en-us/library/6t169e9c(VS.80).aspx

Those registers all get clobbered on all function calls.  I assume that
userspace also considers them to get clobbered on system calls as
well.  

What are those special cases you are talking about?  Certain special
cases for entering the kernel where we do save those registers?

Signal handling and ptrace single stepping are two places I would
imagine we have to enter the kernel and preserve those registers.  Is
that why you were suggesting overloading signal delivery?

Thanks for pointing out the problem, though.  This one will be
interesting. :)

-- Dave
