From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH] devcg: cache the last matched whitelist item
Date: Tue, 14 Apr 2009 09:29:53 -0500
Message-ID: <20090414142953.GB6072@us.ibm.com>
References: <49E3E075.6050103@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <49E3E075.6050103-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Li Zefan (lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org):
> While I was doing testing by open/close files like this:
> 	for (i = 0; i < LOOP; i++) {
> 		fd = open("/dev/null");
> 		close(fd);
> 	}
> It got a bit slower when devcg is used, so I made this patch
> to speed it up.
> 
> But walking through whitelist in devcgroup_inode_permission()
> doesn't seem to be a hot-path, if so this patch probably doesn't
> worth it, and it may not work well under real workload.
> 
> Just post it to see if someone thinks it's useful.

Well there is a tendency of some software to repeatedly try to
open the same device - for instance sendmail opens /dev/null a
few times during startup.  But I don't think 4-6 times during startup
justifies a hack like this.

OTOH I didn't expect the lookup to stay a linear linked list walk for
this long :)  I'd be interested to hear the typical size of a whitelist
in your or openvz's experience, so we could see if a hash fn or some
other speedup makes sense.  We also could consider taking a few entries
- like /dev/{u,}random, /dev/null, /dev/console, and /dev/zero, and
taking them out of the loop.

How much of a slow-down were you seeing in your loop, and how many
whitelist entries did you have?

-serge
