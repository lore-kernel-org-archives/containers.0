From: Rob Landley <rob-VoJi6FS/r0vR7s880joybQ@public.gmane.org>
Subject: Re: For review: pid_namespaces(7) man page
Date: Tue, 05 Mar 2013 19:58:37 -0600
Message-ID: <1362535117.7276.6@driftwood>
References: <87k3pnhx2k.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="Flowed"; DelSp="Yes"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87k3pnhx2k.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> (from ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org on
	Mon Mar  4 11:52:19 2013)
Content-Disposition: inline
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: linux-man <linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On 03/04/2013 11:52:19 AM, Eric W. Biederman wrote:
> > How about this:
> >
> >        The  point  here is that unshare(2) and setns(2) change the  
> PID
> >        namespace for processes subsequently created by the caller,  
> but
> >        not  for the calling process, while clone(2) CLONE_VM  
> specifies
> >        the creation of a new thread in the same process.
> 
> Hmm.  How about this.
> 
>          The point here is that unshare(2) and setns(2) change the PID
>          namespace that will be used by in all subsequent calls to  
> clone
>          and fork by the caller, but not for the calling process, and
>          that all threads in a process must share the same PID
>          namespace.  Which makes a subsequent clone(2) CLONE_VM
>          specify the creation of a new thread in the a different PID
>          namespace but in the same process which is impossible.

CLONE_VM and CLONE_NEWPID are incompatible because all threads of the  
same process must be in the same PID namespace. Since unshare(2) and  
setns(2) change the PID namespace for subsequent calls to clone(2),  
those subsequent calls cannot create new threads (unless you setns(2)  
back to the original namespace first).

That last bit's a guess. :)

Rob
