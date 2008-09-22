From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 10/10] Document usage of multiple-instances of devpts
Date: Mon, 22 Sep 2008 08:29:37 -0500
Message-ID: <20080922132937.GA11932@us.ibm.com>
References: <20080912174845.GA17350@us.ibm.com>
	<20080912175347.GK17350@us.ibm.com>
	<20080919163311.626b715f@lxorguk.ukuu.org.uk>
	<20080920161717.GA23693@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080920161717.GA23693-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org (sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> Alan Cox [alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org] wrote:
> | Ok I'm happy with this patch set. It appears correct as far as the tty
> | side is concerned, it looks sensible in terms of interface with the
> | devpts layer.
> 
> Alan, Peter: Thanks for review and feedback.
> 
> | 
> | Really depends what everyone else thinks about the vfs bits and the API
> 
> Maybe I should post to fsdevel, manpages, and lkml for the vfs/api changes. 
> 
> Serge, Eric, Pavel: Any comments on the patchset before I do that ?

I didn't have any comments on the code, it looked fine.  But the
kernel locked up for me trying to ssh into a container last night.
Complete lockup so haven't yet figured out why.

Oh, actually I did have a comment on code - finding that config
variable was dreadful :)  Now obviously it makes sense on the
one hand, but finding that plus CONFIG_NET_NS plus the other
namespace variables is getting ugly.

-serge
