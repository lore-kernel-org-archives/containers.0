From: Whit Blauvelt <whit-M6G8SDWvnhfby3iVrkZq2A@public.gmane.org>
Subject: Re: How do containers tie to multiple IP's on a NIC?
Date: Wed, 7 Jul 2010 09:22:06 -0400
Message-ID: <20100707132206.GA16692@transpect.com>
References: <20100704034023.GA29753@transpect.com> <4C30BC16.9090802@free.fr>
	<20100704191841.GA31425@transpect.com> <4C30E5CB.1080902@free.fr>
	<20100704230827.GA1066@transpect.com> <4C31AAEE.5010201@gmail.com>
	<20100705140750.GA3113@transpect.com>
	<m1sk3vjvt1.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m1sk3vjvt1.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Jul 07, 2010 at 05:55:22AM -0700, Eric W. Biederman wrote:

> paired veth devices are interesting because you can put one end of a
> logical tunnel in each network namespace.
> 
> macvlan devices are interesting because you can create assign multiple
> mac addresses to a nic and have a different network device for each
> mac address.

These two statements could be section headers in a valuable article - or
book chapter.

The problem with the standard VM concep: it takes the metaphor of separate
computers too literally. The potential for lessening the materials expense
and environmental cost of producing so much hardware and the electricity to
power it - is huge. Conversion to containers instead of VMs can be a major
economic win.

But only if the knowledge of how to do it becomes widespread. 

Whit
