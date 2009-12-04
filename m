From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: ckpt-v19-rc2
Date: Fri, 4 Dec 2009 12:17:32 -0600
Message-ID: <20091204181732.GA29195@us.ibm.com>
References: <Pine.LNX.4.64.0912012352420.5665@takamine.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0912012352420.5665-CXF6herHY6ykSYb+qCZC/1i27PF6R63G9nwVQlTi/Pw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> 
> I put together ckpt-v19-rc2 (kernel and user) that includes:
> 
> * eclone
> * INET sockets
> * timerfd, signalfd
> * rebase to 2.6.32-rc8
> * c/r thread/cpu state earlier
> * misc fixes
> 
> Hoping to give it some testing to clean remaining rough edges, and
> in particular net-c/r patches whose folding wasn't trivial, as well
> as the other archs.
> 
> On the todo-list are:
> 
> * assorted cleanup/fixes
> * more cleanups on ckpt_err/ckpt_msg
> * support for x86-64
> * unlinked files (if ready ?)

Ok, I only just realized, through a segfault on restart, that
current->fs->pwd isn't being restored.  Were you thinking of
supporting that in v19?

If we don't want to do 'proper' current->fs c/r, I htink it's
worthwhile doing a cheap c/r of current->fs->pwd as a filename.

(I'd send the cheap patch, but am mostly out from now until wed)

thanks,
-serge
