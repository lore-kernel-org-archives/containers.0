From: "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
Subject: Re: [LTP] [PATCH 0/4] Helper patches for PTY namespaces
Date: Wed, 23 Apr 2008 11:01:19 -0700
Message-ID: <480F796F.3040906@zytor.com>
References: <20080412172933.GA19295@us.ibm.com>
	<bb33bcf20804121039u409ae37q2dead849ca24dfa@mail.gmail.com>
	<20080412180533.GE19449@us.ibm.com>
	<1208172006.5762.21.camel@subratamodak.linux.ibm.com>
	<OF766ECBB8.8B7DAFCE-ON6525742B.00437346-6525742B.0043FD8A@in.ibm.com>
	<1208176260.5762.36.camel@subratamodak.linux.ibm.com>
	<1208848319.4847.16.camel@subratamodak.linux.ibm.com>
	<20080422122530.GB8331@sergelap.austin.ibm.com>
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
Cc: ltp-list <ltp-list-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, Veerendra Chandrappa <vechandr-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, Rishikesh K Rajak <risrajak-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Subrata Modak <subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Serge E. Hallyn wrote:
> 
> Subrata,
> 
> pty namespaces as such are not going to happen.  We'll be pursuing
> full-scale device namespaces instead.
> 

Again, either that, or tie Unix98 pty's closer into devpts (which would 
have other advantages, in particular avoiding the double lookup) which 
would permit the ordinary filesystem namespace mechanisms to be used.

	-hpa
