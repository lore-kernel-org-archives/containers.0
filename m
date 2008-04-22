From: Subrata Modak <subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [LTP] [PATCH 0/4] Helper patches for PTY namespaces
Date: Tue, 22 Apr 2008 20:38:09 +0530
Message-ID: <1208876889.4847.38.camel@subratamodak.linux.ibm.com>
References: <20080412172933.GA19295@us.ibm.com>
	<bb33bcf20804121039u409ae37q2dead849ca24dfa@mail.gmail.com>
	<20080412180533.GE19449@us.ibm.com>
	<1208172006.5762.21.camel@subratamodak.linux.ibm.com>
	<OF766ECBB8.8B7DAFCE-ON6525742B.00437346-6525742B.0043FD8A@in.ibm.com>
	<1208176260.5762.36.camel@subratamodak.linux.ibm.com>
	<1208848319.4847.16.camel@subratamodak.linux.ibm.com>
	<20080422122530.GB8331@sergelap.austin.ibm.com>
Reply-To: subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080422122530.GB8331-6s5zFf/epYLPQpwDFJZrxKsjOiXwFzmk@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: ltp-list <ltp-list-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, Veerendra Chandrappa <vechandr-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, Rishikesh K Rajak <risrajak-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 2008-04-22 at 07:25 -0500, Serge E. Hallyn wrote:
> Quoting Subrata Modak (subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> > On Mon, 2008-04-14 at 18:01 +0530, Subrata Modak wrote:
> > > On Mon, 2008-04-14 at 18:01 +0530, Veerendra Chandrappa wrote:
> > > > Hi Sukadev,
> > > > 
> > > >       That sounds nice, I will integrate them with the LTP.
> > > > Of course it depends on the order of priority, and as I am learning the
> > > > tricks of container/ltp .
> > > 
> > > That is cool Veerandra. Now, for this to move forward, Suka needs to
> > > hand over those test cases to you ;-)
> > 
> > Veerandra,
> > 
> > Have you already received those test cases from Suka ?
> 
> Subrata,
> 
> pty namespaces as such are not going to happen.  We'll be pursuing
> full-scale device namespaces instead.
> 

Oops.

device namespaces test cases are also welcome in future.

Regards--
Subrata

> thanks,
> -serge
