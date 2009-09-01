From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: [lxc-devel] LXC quota support
Date: Tue, 01 Sep 2009 20:32:49 +0200
Message-ID: <4A9D68D1.5030807@free.fr>
References: <ac1c4bf20909010930q5721c9bas2ea3722e94657820@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <ac1c4bf20909010930q5721c9bas2ea3722e94657820-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: kt-S89nZTSLPHGGdvJs77BJ7Q@public.gmane.org
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

Krzysztof Taraszka wrote:
> Hello,
> 
> I am looking for quota support for LXC containers. For example, I would like
> to have two containers.  One of them may have 20GB, second 50GB.
> I found this one patch:
> https://lists.linux-foundation.org/pipermail/containers/2009-February/015807.htmland
> I have a question. Does there is another implemented method for have
> disk quota for container and his cgrop ? How about rootfs available disk
> space information ? If no, is there any ideas how to and when the disk quota
> will be implemented?

Anqui did a first try with this patch. The feature was positively 
received but not in this form. I don't know what is the status of this 
work, but maybe Anqui can give an answer :) - Cc'ed.

Anqui ? Did you tried to implement quotas with the directory hierarchy 
level as suggested Paul ?

Krzysztof, one solution to restrict disk usage to a container can be to 
create an disk image of 20GB, mount it on a directory, install the 
rootfs on it and use this directory as the rootfs for the container.

  -- Daniel

ps: The disk image should be a sparse file ;)
