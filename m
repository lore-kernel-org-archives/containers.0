From: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Subject: Re: [CRIU] CRIU @Plumbers
Date: Tue, 03 Feb 2015 07:52:50 -0800
Message-ID: <1422978770.2090.2.camel@HansenPartnership.com>
References: <54CF4BFF.8070505@parallels.com>
	<20150202165852.GC24351@ubuntumail>
	<1422935454.2103.48.camel@HansenPartnership.com>
	<20150203154123.GB2923@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20150203154123.GB2923-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
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
Cc: CRIU <criu-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 2015-02-03 at 16:41 +0100, Serge E. Hallyn wrote:
> Quoting James Bottomley (James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org):
> > On Mon, 2015-02-02 at 16:58 +0000, Serge Hallyn wrote:
> > > I think it might be worthwhile - my main concern is that it not conflict
> > > timewise with the containers summit.
> > 
> > You mean ContainerCon?  That's running concurrently with LinuxCon, so it
> > shouldn't conflict with either of the two plumbers days.
> 
> Sorry didn't mean "summit".  I just mean the containers track at plumbers.
> 
> http://wiki.linuxplumbersconf.org/2015:containers

Yes, Plumbers can take care of the scheduling.  Since we have a Seattle
local team, we'll help running containers, which should make sure
there's no overlap ...

James
