From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: Sending data between two nics on one machine
Date: Sat, 27 Oct 2012 21:58:43 -0700
Message-ID: <87mwz78a64.fsf@xmission.com>
References: <CAHvNds2pUmqisQOtMn0-T-SAKrNs40THY80+Pwi-MNgPwDZNcQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAHvNds2pUmqisQOtMn0-T-SAKrNs40THY80+Pwi-MNgPwDZNcQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Jereme Lamps's message of "Wed, 24 Oct 2012 22:45:39 -0500")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jereme Lamps <lamps1-nzINlOoChub2fBVCVOL8/A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Jereme Lamps <lamps1-nzINlOoChub2fBVCVOL8/A@public.gmane.org> writes:

> I have a machine (ubuntu 12.04) with 2 nics and I am trying to send data
> between the two. However, when I iperf from one to the other, the OS is
> optimizing it and the data is never actually being sent out on the network
> (I want it to go through the switch).
> Is there any way I can move one of the physical interfaces into a network
> namespace and then try to iperf from there?
>
> Any help would be greatly appreciated!

ip netns add ...
ip link set ...
ip netns exec ...

Eric
