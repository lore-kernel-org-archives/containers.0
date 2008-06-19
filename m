From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] cryo: test program for udp sockets
Date: Thu, 19 Jun 2008 17:19:22 -0500
Message-ID: <20080619221922.GA9485@us.ibm.com>
References: <20080619161743.125447871@theryb.frec.bull.fr>
	<20080619161748.311591836@theryb.frec.bull.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080619161748.311591836-4vkkeT0zb4ZEtYaxpPmRp1aPQRlvutdw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Benjamin Thery (benjamin.thery-6ktuUTfB/bM@public.gmane.org):
> Here is the small test program I use to test checkpoint/restart of UDP
> sockets with cryo. 
> This program can be called either as a server listening on a given port 
> on a given adresse, or a client sending message to a given address on a
> given port. The client sends integer and the server sums them.
> 
> Run two instances of sockudp, one server and one client. 
> Checkpoint the server.
> Stop both instances.
> Restart server. He will wait for more messages.
> Run a new client. The server will continue to sum the data it receives!
> 
> Signed-off-by: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>

Hey that works beautifully.  Checkpointed both the client and server
played with killing and restarting them both.

Applied to git tree.

thanks,
-serge
