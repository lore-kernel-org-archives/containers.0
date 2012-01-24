From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC] fix devpts mount behavior
Date: Tue, 24 Jan 2012 12:16:00 -0800
Message-ID: <20120124201600.GB20039__15360.9085748487$1327436283$gmane$org@us.ibm.com>
References: <20120124000517.GA28878@sergelap>
	<CA+55aFz9ofF+Ey8VCDS8UEf2XSw36kj2RhkHfFScuzLXMeNrkA@mail.gmail.com>
	<20120124002555.GA29534@sergelap>
	<CA+55aFzwOU137V6wtyBjessx05NJo2G4KV0rvTKWvC79A+o9iQ@mail.gmail.com>
	<20120124010758.GJ23916@ZenIV.linux.org.uk>
	<20120124182116.GA11715@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120124182116.GA11715-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Hansen <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Andy Whitcroft <apw-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Serge Hallyn [serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org] wrote:
| Quoting Al Viro (viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org):
| > On Mon, Jan 23, 2012 at 04:41:25PM -0800, Linus Torvalds wrote:
| > 
| > > Right. I think the opportunity for problems should be pretty small.
| > > 
| > > And it's not like the pty itself wouldn't continue to work - it's just
| > > that programs like /usr/bin/tty wouldn't be able to *find* it.
| > > 
| > > Although who knows - maybe there is some other subtle interaction.
| > 
| > FWIW, the subtle and nasty part in all that is  that you can mknod /dev/ptmx
| > and it *will* work, refering to the "initial" instance.  That's what
| > concerns me about the chroot scenarios -
| > 	mknod /jail/dev/ptmx c 5 2
| > 	mkdir /jail/dev/pts
| > 	mount -t devpts /jail/dev/pts
| > 	chroot /jail
| > works fine right now, but with that change behaviour will be all wrong -
| > opening /dev/ptmx inside of jail will grab you a pts, all right, but
| > it will *not* show up in (jail) /dev/pts/* as it does with the current
| > kernel.
| > 
| > Note that if you replace that mknod with symlink pts/ptmx /jail/dev/ptmx
| > the things will keep working.  However, that will _only_ work for kernels
| > with DEVPTS_MULTIPLE_INSTANCES - without it you won't get ptmx inside
| > devpts (which is arguably wrong, BTW)
| 
| Should /dev/pts/ptmx be created for DEVPTS_MULTIPLE_INSTANCES=n?

With DEVPTS_MULTIPLE_INSTANCES=n, there is only _one_ (global) instance
right ? Why would we need a 'pts/ptmx' node ? To keep the symlink (i.e
user space scripts) valid for both single and multiple instance cases ?

Sukadev
