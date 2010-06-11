From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: VRF-like use of Network Namespaces
Date: Fri, 11 Jun 2010 07:59:17 -0700
Message-ID: <878w6lobsq.fsf@caffeine.danplanet.com>
References: <AANLkTimA_0aZwZM1uZ-GH3OxfEZvegoitaaKTYPLvW5F@mail.gmail.com>
	<4C0E6466.3030100@free.fr>
	<AANLkTik77W7F7BV7qp9ZQlM3yJCKNydHAMN47FaLTr7Z@mail.gmail.com>
	<4C0EB0C5.8070904@free.fr>
	<AANLkTinmsRRKdWaf8QONeRRJSQRXPhaUtY1cFv_JGcy8@mail.gmail.com>
	<AANLkTilUNrMAeeUjHsXkTwd7Ysx0o9mdl8UaSUvG6wvf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <AANLkTilUNrMAeeUjHsXkTwd7Ysx0o9mdl8UaSUvG6wvf-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Mathieu Peresse's message of "Fri\,
	11 Jun 2010 16\:47\:00 +0200")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Mathieu Peresse <mathieu.peresse-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

MP> I saw there was a rtnetlink attribute to set the netns of a device but it
MP> uses the PID of a namespace owner to do so... within 'ip' i can refer to
MP> only one namespace (i.e. the one that 'ip' task_struct->ns_proxy currently
MP> points to), so I won't be able to move an interface from outside my
MP> namespace to my namespace...

Not just the owner, but any process in the namespace, AFAIK.  So, you
should be able to fork() a child, have that child setns() into the
namespace of your choosing, and then move the device to the process of
your child (since you now know the pid).  It's a little indirect, but
it should work.

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
