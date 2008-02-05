From: Dave Hansen <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2.6.24-rc8-mm1 09/15] (RFC) IPC: new kernel API to
	change an ID
Date: Tue, 05 Feb 2008 10:00:25 -0800
Message-ID: <1202234426.10699.209.camel__25745.3307662674$1202234647$gmane$org@nimitz.home.sr71.net>
References: <20080129160229.612172683@bull.net>
	<20080129162000.454857358@bull.net>
	<20080129210656.GB1990@martell.zuzino.mipt.ru>	<47A18E47.5050206@bull.net>
	<47A19AC2.7040709@sw.ru> <47A1B78C.7050405@bull.net>
	<47A83194.8060808@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47A83194.8060808-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 2008-02-05 at 04:51 -0500, Oren Laadan wrote:
> That said, I suggest the following method instead (this is the method
> we use in Zap to determine the desired resource identifier when a new
> resource is allocated; I recall that we had discussed it in the past,
> perhaps the mini-summit in september ?):
> 
> 1) The process/thread tells the kernel that it wishes to pre-determine
> the resource identifier of a subsequent call (this can be done via a
> new syscall, or by writing to /proc/self/...).
> 
> 2) Each system call that allocates a resource and assigns an
> identifier
> is modified to check this per-thread field first; if it is set then
> it will attempt to allocate that particular value (if already taken,
> return an error, eg. EBUSY). Otherwise it will proceed as it is today.

You forgot to attach the patch to your mail. ;)

-- Dave
