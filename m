From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 9/9] Document usage of multiple-instances of devpts
Date: Wed, 15 Oct 2008 14:48:22 -0500
Message-ID: <20081015194822.GB2434@us.ibm.com>
References: <20081015053000.GA2039@us.ibm.com>
	<20081015053800.GI2215@us.ibm.com>
	<20081015185722.GA30005@us.ibm.com> <48F63E76.3030907@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <48F63E76.3030907-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
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
Cc: kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, "David C. Hansen" <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting H. Peter Anvin (hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org):
> Serge E. Hallyn wrote:
>> Looks good.  In the very last part, you might say just a little more to
>> make sure it's clear:  You want to mount -o newinstance before sshd
>> or gnome is started in the root container, so that a child container
>> can't reach your devpts by doing a mount -t devpts without -o
>> newinstance.  It's not that it's not clear in what you write, it's
>> more that it's at the very end and brief, so I'm afraid it's not
>> attention-grabbing enough as is.
>
> Actually, you should just enable newinstance everywhere, in particular  
> in your fstab, so that ALL instances of devpts in the system have  
> newinstance (leaving the legacy one unreachable.)
>
> In that sense I think your text above is more confusing than what  
> Sukadev had.
>
> 	-hpa

That's fine, I just want a clearer louder warning that without that, a
container is not isolated from your devpts.

Maybe just 'WARNING" above point 7?

Or just leave it.  You're right, his text is plenty clear.

-serge
