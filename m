From: "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC][PATCH 7/8]: Auto-create ptmx node when mounting devpts
Date: Thu, 21 Aug 2008 11:36:47 -0700
Message-ID: <48ADB5BF.4060408@zytor.com>
References: <20080821022126.GA29449@us.ibm.com>	<20080821022908.GG29658@us.ibm.com>	<20080821102139.43c44f67@lxorguk.ukuu.org.uk>	<48AD932F.8090908@zytor.com>	<20080821172700.781b0011@lxorguk.ukuu.org.uk>	<48AD9C93.6080302@zytor.com>
	<20080821172342.GA8059@us.ibm.com>	<m18wuqtgj7.fsf@frodo.ebiederm.org>
	<48ADAAE2.6040700@zytor.com> <m1hc9eqlbo.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1hc9eqlbo.fsf-B27657KtZYmhTnVgQlOflh2eb7JE58TQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Eric W. Biederman wrote:
> 
> The point of making it a bind is to address the concerns about
> backwards compatibility in user space.  In particular security
> conscious applications and applications that perform sanity checks
> are known to ignore things if they are the wrong type in the filesystem.
> 

A.k.a. broken applications...

>> This is *only* required to support back-and-forth, and can be introduced at any
>> time after this patch is in the kernel -- or even before.
> 
> You can use a file bind mount just as easily as a symlink.
> 
> As for udev I haven't seen a version that is accessible to mere mortals yet
> and it doesn't seem like they plan on it being so.  Eventually I will get
> around to making sense of it as we need to make it work in a container
> but so far it seems to be much more complex then it should be.

I have not had that experience... I find it relatively simple to deal 
with.  The biggest problem is the fact that the rules aren't bundled 
with the kernel, which causes nasty chicken and egg problems.

	-hpa
