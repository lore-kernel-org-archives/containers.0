From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC] Container mini-summit agenda for Sept 3, 2007
Date: Mon, 03 Sep 2007 13:32:46 +0400
Message-ID: <46DBD4BE.4000901@openvz.org>
References: <46D69653.1090003@fr.ibm.com> <46DBC9C5.5060101@fr.ibm.com>
	<6599ad830709030203s50ad1ab1vb0cdf21be0ab023@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830709030203s50ad1ab1vb0cdf21be0ab023-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Kir Kolyshkin <kir-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Rohit Seth <rohitseth-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, office-xGb7/i2pWyrYtjvyW6yDsg@public.gmane.org, Alasdair Kergon <agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> On 9/3/07, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> wrote:
>>         http://download.openvz.org/~xemul/minisummit.odp
>>
> 
> I notice ?s against "Task scheduler" and "Network scheduler".
> 
> Is "Task scheduler" meant to represent "CPU scheduler" or "task count
> limit". If the former, CFS in the mainline should provide a lot of
> what we need, and has already been linked with task containers by
> Srivatsa Vaddagiri.

Yes, task scheduler is the CPU scheduler.

> Network scheduling is already fairly advanced in Linux - all we need
> is a way to be able to feed container information into existing Linux
> traffic control concepts. We've played with an approach that lets us
> tag a container with a particular id, and then use that id as the
> primary classifier in a standard HTB controller, and it seems to be
> fairly successful.
> 
> Paul
> 
