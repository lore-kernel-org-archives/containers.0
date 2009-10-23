From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] fix compile with CONFIG_CHECKPOINT_DEBUG=n
Date: Fri, 23 Oct 2009 14:46:41 -0500
Message-ID: <20091023194641.GA29761@us.ibm.com>
References: <20091022143238.GA31778@us.ibm.com> <4AE1FB87.4050305@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4AE1FB87.4050305-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org):
> 
> 
> Serge E. Hallyn wrote:
> > On the one hand, compiling without checkpoing debug saves a
> > lot of kernel size:
> > 
> > with debug:
> > -rwxrwxr-x  1 hallyn hallyn  62391508 Oct 21 22:08 vmlinux
> > without debug:
> > -rwxrwxr-x  1 hallyn hallyn  62298077 Oct 21 22:33 vmlinux
> > 
> > OTOH the need for this patch just proves my point that we don't
> > want any more config options than we need (especially no
> > CONFIG_CHECKPOINT_LOGGING in addition to _DEBUG).
> > 
> > So that begs the question - is there something we can do to
> > avoid having to recompile the kernel to turn on debugging,
> > but not take up 100k of space in vmlinux?  Maybe get rid of
> > the ckpt_debugs altogether and instead provide pre-written
> > kprobe sets to turn on debugging at specific places?
> 
> What is the reason for the increase - the strings ? the extra
> inlined code ?  the passing of variables to printed ?

Half and half :)

Pulling out the 'current->pid' and task_pid_nr arguments in
_ckpt_debug to printk, but keeping the __func__ and __LINE__,
halves the overhead of CONFIG_CHECKPOINT_DEBUG from
78190 to 39809 bytes.

-serge
