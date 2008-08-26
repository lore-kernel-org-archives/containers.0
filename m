From: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Subject: Re: [RFC][PATCH 1/3] Move parts of init_dev() into new functions
Date: Tue, 26 Aug 2008 10:44:45 +0100
Message-ID: <20080826104445.06d36dd2@lxorguk.ukuu.org.uk>
References: <20080825201110.GA32440@us.ibm.com>
	<20080825211146.70b4af63@lxorguk.ukuu.org.uk>
	<20080825220125.GA1084@us.ibm.com> <48B33072.4080509@zytor.com>
	<20080825232003.3574a181@lxorguk.ukuu.org.uk>
	<48B34818.2000400@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48B34818.2000400-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
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
Cc: kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

> > Only for a re-open - which is very different to an initial open,
> > and /dev/tty is deep magic in this situation.
> 
> I guess I fail to understand something here, perhaps because I haven't 
> looked at the code in very much details for several years.  How is there 
> not a 1:1 mapping between tty structures and instances, even in the 
> presence of /dev/tty?  (/dev/tty, of course, points to a real tty.)

In the case of the initial open you don't yet know the tty pointer and
may be creating it. SO the tty isn't a reference because it doesn't exist.

> *Nod.*  It may mean that for consoles we have to provide transient 
> inodes in rootfs.

consoles for printk need to exist extremely early if we are going to be
able to kick most of the console special case code into the bitbucket.

Alan
