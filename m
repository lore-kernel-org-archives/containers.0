From: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Subject: RE: [PATCH 0/9] use network namespace for iSCSI control interfaces
Date: Tue, 21 Nov 2017 11:26:09 +0000
Message-ID: <687d0196888f4325aebc0989a8e12ced__1641.91902517832$1511263568$gmane$org@AcuMS.aculab.com>
References: <20171107180156.GD29597@straylight.hirudinean.org>
	<20171107224513.4217-1-cleech@redhat.com>
	<063D6719AE5E284EB5DD2968C1650D6DD00B618E@AcuExch.aculab.com>
	<20171115002521.GA21082@straylight.hirudinean.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20171115002521.GA21082-r8IHplWLGbA5tHQWs+pTeqPFFGjUI2lm2LY78lusg7I@public.gmane.org>
Content-Language: en-US
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: 'Chris Leech' <cleech-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Chris Leech
> Sent: 15 November 2017 00:25
> To: David Laight
> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> Subject: Re: [PATCH 0/9] use network namespace for iSCSI control interfaces
> 
> On Wed, Nov 08, 2017 at 10:31:04AM +0000, David Laight wrote:
> > From: Chris Leech
> > > Sent: 07 November 2017 22:45
> > >
> > > I've posted these changes to allow iSCSI management within a container
> > > using a network namespace to the SCSI and Open-iSCSI lists, but seeing
> > > as it's not really SCSI/block related I'm casting a wider net looking
> > > for reviews.
> >
> > I didn't spot you acquiring and releasing references to the namespace.
> > (I might have missed it, the relevant patch is difficult to read).
> >
> > If the sockets are created in the context of the process whose namespace
> > you are using you don't need it, but given the hooks and callbacks
> > I'm not at all sure that is obviously true.
> 
> Thanks David,
> 
> Looking at it again, you're right and I think I need to hold a reference
> for the iSCSI host and handle namespace deletion.  Even for iscsi_tcp
> the socket gets handed off from the creating process to the transport
> and can outlive iscsid.

It isn't that simple....
IIRC:

The namespace delete callback isn't made until the reference count is zero.
Sockets created with sock_create_kern() don't hold a reference to the
namespace

This is all fine for sockets used for admin purposes, but rather hopeless
if you really need the namespace to continue to exist while the connections
are open - if only for long enough to close the connection.

To make matters even more annoying the functions for holding and
releasing a namespace are GPL_ONLY :-(

	David
