From: "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 11/11][v3]: Enable multiple instances of devpts
Date: Thu, 04 Sep 2008 09:48:35 -0700
Message-ID: <48C01163.1050704@zytor.com>
References: <20080904052718.GA3680@us.ibm.com>	<20080904053551.GL3680@us.ibm.com>	<48BF8283.7040601@zytor.com>	<20080904155431.GA11174@us.ibm.com>	<48C00698.8050803@zytor.com>
	<20080904172542.3ad7bb85@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080904172542.3ad7bb85-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Cc: kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

Alan Cox wrote:
> O> We can't, really, because it will open the global ptmx.  This is an 
>> unfortunate side effect of the backwards-compatibility code.
>>
>> This is also why I don't like the bind mount; the symlink option has the 
>> nice property that f*ckups are more obvious.
> 
> It's asking for trouble with existing systems and users that
> upgrade. /dev/ptmx should remain a proper device file for the non
> container case.

I did say that as being the desired *eventual* goal.

> Should /dev/ptmx give you a node in the 'master' pty namespace or a node
> in your current containers pty namespace ?

Well, since there is no "current containers pty namespace" per se, it 
will give you a node in the default (initial) pty namespace unless the 
bind mount is set up.

	-hpa
