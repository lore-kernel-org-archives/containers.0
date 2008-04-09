From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: Re: [RFC][PATCH 0/7] Clone PTS namespace
Date: Wed, 9 Apr 2008 09:23:53 -0700
Message-ID: <20080409162353.GA14044@us.ibm.com>
References: <20080408215333.GA8799@us.ibm.com> <47FC138B.4070408@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <47FC138B.4070408-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

H. Peter Anvin [hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org] wrote:
> sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
>> Devpts namespace patchset
>> In continuation of the implementation of containers in mainline, we need 
>> to
>> support multiple PTY namespaces so that the PTY index (ie the tty names) 
>> in
>> one container is independent of the PTY indices of other containers.  For
>> instance this would allow each container to have a '/dev/pts/0' PTY and
>> refer to different terminals.
>
> Why do we "need" this?  There isn't a fundamental need for this to be a 
> dense numberspace (in fact, there are substantial reasons why it's a bad 
> idea; the only reason the namespace is dense at the moment is because of 
> the hideously bad handing of utmp in glibc.)  Other than indicies, this 
> seems to be a more special case of device isolation across namespaces, 
> would that be a more useful problem to solve across the board?

We want to provide isolation between containers, meaning PTYs in container
C1 should not be accessible to processes in C2 (unless C2 is an ancestor).

The other reason for this in the longer term is for checkpoint/restart.
When restarting an application we want to make sure that the PTY indices
it was using is available and isolated.

We started out with isolating just the indices but added the special-case
handling for granting the host visibility into a child-container.

A complete device-namespace could solve this, but IIUC, is being planned
in the longer term. We are hoping this would provide the isolation in the
near-term without being too intrusive or impeding the implementation of
the device namespace.

Sukadev
