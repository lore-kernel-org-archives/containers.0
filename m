From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] [RFC] user-cr: Eliminate SUBARCH from Makefile
Date: Fri, 26 Feb 2010 14:54:29 -0600
Message-ID: <1267217669.15300.118.camel@localhost.localdomain>
References: <0c6c11c99f939c74b86893d5eac268ce5c612fe7.1267216666.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <0c6c11c99f939c74b86893d5eac268ce5c612fe7.1267216666.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux-Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, 2010-02-26 at 12:37 -0800, Matt Helsley wrote:
> [ Depends on recent series of non-RFC Makefile patches ]
> 
> SUBARCH is gross. We shouldn't need to detect the arch to compile to
> using uname. It's bad practice because we could be using a cross compiler,
> or someone may (gag) autoconfiscate this tree. If we must select a true
> subarch, we should just let builders set -mXX in CFLAGS.
> 
> This patch tries to build all of the clone_*.[cSs] files. Any builds
> that fail are quietly ignored and don't get used. One that succeeds
> gets hardlinked to clone.a and subsequently linked into libeclone.a

Hmm, I think detecting the architecture via uname is fine as long as the
user is able to override it (make SUBARCH=foo).

I don't think trying to compile all of clone_* is going to be a good
practice.  For one thing, gcc -m64 on powerpc happily accepted the
32-bit clone wrapper the last time I tried it, hence the #error
directives in clone_ppc*.S.
