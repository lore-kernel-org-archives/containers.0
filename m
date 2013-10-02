From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: Device Namespaces
Date: Wed, 02 Oct 2013 15:55:51 -0700
Message-ID: <87r4c3mgeg.fsf@xmission.com>
References: <CAA2m6vexArJ+6jFbK80Amstk=LK30=XDNHdBHSswP=LgpSP-6A@mail.gmail.com>
	<871u4yddg4.fsf@xmission.com>
	<CAA2m6vc_kWWGDWcdjk26N3YvTqZySLFxPQRjOD9_ypBOka2+GQ@mail.gmail.com>
	<CAE=NcrbyFFoMn2nfBA_=ZtwD=eGLvqK=L-U9MuGrtJFLZfZppw@mail.gmail.com>
	<87bo3gshz5.fsf_-_@xmission.com> <20130926053320.GB3725@kroah.com>
	<CAE=NcrYV2RiMV7PcwEjFGFRBrz9XdZGs86Wau2a+6xpYN2aEHA@mail.gmail.com>
	<CALCETrWWoHzuJcnfEUY+cFpOgT5gnG8U1cVbCW0_8V7Z_v6DJw@mail.gmail.com>
	<20131001175345.GA4145@mail.hallyn.com> <87had0wz07.fsf@xmission.com>
	<20131001204605.GA11894@tp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20131001204605.GA11894@tp> (Serge Hallyn's message of "Tue, 1
	Oct 2013 15:46:05 -0500")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Cc: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, Stephane Graber <stgraber-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, lxc-devel <lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, mhw <mhw-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, devel <devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org> writes:

>> Glossing over the details.  The general problem is some policy exists
>> outside of the container that deciedes if an when a container gets a
>> serial port and stuffs it in.
>> 
>> The expectation is that system containers will then run the udev
>> rules and send the libuevent event.  
>
> I thought the suggestion was that udev on the host would be given
> container-specific rules, saying "plop this device into /dev/container1/"
> (with /dev/container1 being bind-mounted to $container1_rootfs/dev).

That is what I was trying to describe.  We still need something that
lets the software in the container know it needs to do something.

I may be blind but right now short of replacing the internal udev, or
modifying the kernel I don't see a solution for letting software in a
container know there is a new device it can use.

Once we get the notification issue sorted out I think we have enough to
bring up a full desktop environment in a container and be able to say we
don't need anything else from devices unless someone discovers that
checkpoint/restart actually needs minor numbers to be preserved.

Eric
