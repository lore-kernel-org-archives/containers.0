From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: Re: [PATCH 0/4] Devices accessibility control group (v2)
Date: Mon, 14 Jan 2008 09:42:20 -0800
Message-ID: <20080114174220.GA17825@us.ibm.com>
References: <47833C3A.8090106@openvz.org> <20080112212014.GA12085@us.ibm.com>
	<478B14DB.4000106@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <478B14DB.4000106-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

| > I started playing with this and noticed that even if I try to
| > enable read access to device [c, 1:3] it also grants access
| > to device [c, 1:5]. 
| 
| Hm... I can't reproduce this:
| 
| # /bin/echo 'c 1:3 r-' > /cnt/dev/0/devices.permissions
| # /bin/echo -n $$ > /cnt/dev/0/tasks
| # cat /cnt/dev/0/devices.permissions 
| c 1:3 r-
| # hexdump /dev/null 
| # hexdump /dev/zero 
| hexdump: /dev/zero: No such device or address
| hexdump: /dev/zero: Bad file descriptor
| 
| Maybe you have played with devs cgroups before getting this?
| Can you show what's the contents of the devices.permissions file
| in your case?

Here is the repro again. I even tried after a reboot. Basically,
granting access to /dev/null is also granting access to /dev/zero.

	# cat devices.permissions
	# hexdump /dev/zero
	hexdump: /dev/zero: No such device or address
	hexdump: /dev/zero: Bad file descriptor
	# hexdump /dev/null
	hexdump: /dev/null: No such device or address
	hexdump: /dev/null: Bad file descriptor
	# echo 'c 1:3 r-' > devices.permissions
	# hexdump /dev/null
	# hexdump /dev/zero
	0000000 0000 0000 0000 0000 0000 0000 0000 0000
	*
	^C
	# cat tasks
	3279
	22266
	# ps
	  PID TTY          TIME CMD
	 3279 pts/0    00:00:00 bash
	22267 pts/0    00:00:00 ps
