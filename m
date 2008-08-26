From: "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC][PATCH 1/3] Move parts of init_dev() into new functions
Date: Mon, 25 Aug 2008 17:02:32 -0700
Message-ID: <48B34818.2000400@zytor.com>
References: <20080825201110.GA32440@us.ibm.com>	<20080825211146.70b4af63@lxorguk.ukuu.org.uk>	<20080825220125.GA1084@us.ibm.com>	<48B33072.4080509@zytor.com>
	<20080825232003.3574a181@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080825232003.3574a181-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
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
Cc: kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

Alan Cox wrote:
>> This seems more than a bit redundant.  The "instance", IMO, *is* the tty 
>> structure; so the interface should be:
> 
> Only for a re-open - which is very different to an initial open,
> and /dev/tty is deep magic in this situation.

I guess I fail to understand something here, perhaps because I haven't 
looked at the code in very much details for several years.  How is there 
not a 1:1 mapping between tty structures and instances, even in the 
presence of /dev/tty?  (/dev/tty, of course, points to a real tty.)

>> Not "index", but "inode".  If, as a courtesy to the generic driver, we 
>> want to precalculate the index number we can do that, but otherwise that 
>> is of course available as:
> 
> Thats a much bigger step and raises problems later on with consoles. We
> might want to end up there - but not in one leap.

*Nod.*  It may mean that for consoles we have to provide transient 
inodes in rootfs.

	-hpa
