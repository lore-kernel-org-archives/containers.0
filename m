From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 7/8]: Auto-create ptmx node when mounting devpts
Date: Thu, 21 Aug 2008 12:22:45 -0500
Message-ID: <20080821172245.GA28411@us.ibm.com>
References: <20080821022126.GA29449@us.ibm.com>
	<20080821022908.GG29658@us.ibm.com>
	<20080821102139.43c44f67@lxorguk.ukuu.org.uk>
	<48AD932F.8090908@zytor.com>
	<20080821172700.781b0011@lxorguk.ukuu.org.uk>
	<48AD9C93.6080302@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <48AD9C93.6080302-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
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
Cc: kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting H. Peter Anvin (hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org):
> Alan Cox wrote:
>>> auto-created, than supporting mknod(2) inside the devpts filesystem.  
>>> It's not a matter of "changing the user space"; it's a matter of what 
>>> makes most sense inside the kernel.
>>
>> Having an extra node with different permissions suddenely appear without
>> warning isn't I think good behaviour.
>
> Hm.  Given that the single-instance mode is the backwards compatibility  
> mode (and it's accessible from outside the filesystem), it probably  
> makes sense to suppress creating this device node when *not* applying  
> the "newns" option, or whatever we want to call it.

That makes sense.  But if Suka does that, then is creating the device
when the newns flag is specified ok with you, Alan?

>> I'm open to being convinced and the
>> other problems with that code are more pressing.
>
> Agreed.
>
> 	-hpa

thanks,
-serge
