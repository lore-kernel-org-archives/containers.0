From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: liblxc: lxc-debian
Date: Mon, 8 Dec 2008 17:43:48 -0600
Message-ID: <20081208234348.GA7935@us.ibm.com>
References: <20081204023936.GA31830@us.ibm.com> <4939AFA7.1060903@fr.ibm.com>
	<20081206001110.GA32712@us.ibm.com>
	<1228772669.5558.9.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1228772669.5558.9.camel@localhost>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> > (this is the code i inserted into the old lxc-debian command,
> > haven't checked if i need to change it for the new one)
> > 
> >     echo "lxc.cgroup.devices.deny = a" >> $CONFFILE
> >     # /dev/null and zero
> >     echo "lxc.cgroup.devices.allow = c 1:3 rwm" >> $CONFFILE
> >     echo "lxc.cgroup.devices.allow = c 1:5 rwm" >> $CONFFILE
> >     # consoles
> >     echo "lxc.cgroup.devices.allow = c 5:1 rwm" >> $CONFFILE
> >     echo "lxc.cgroup.devices.allow = c 5:0 rwm" >> $CONFFILE
> >     echo "lxc.cgroup.devices.allow = c 4:0 rwm" >> $CONFFILE
> >     echo "lxc.cgroup.devices.allow = c 4:1 rwm" >> $CONFFILE
> >     # /dev/{,u}random
> >     echo "lxc.cgroup.devices.allow = c 1:9 rwm" >> $CONFFILE
> >     echo "lxc.cgroup.devices.allow = c 1:8 rwm" >> $CONFFILE
> >     # /dev/pts/* - pts namespaces are "coming soon"
> >     echo "lxc.cgroup.devices.allow = c 136:* rwm" >> $CONFFILE
> >     # rtc
> >     echo "lxc.cgroup.devices.allow = c 254:0 rwm" >> $CONFFILE
> 
> This could be a tad prettier with a "here file" rather than all the
> echoes and >> $CONFFILE:

The new lxc-debian actually does

	cat > $CONFIGFILE << EOF

I pasted from my old version.

>         #
>         # Write some reasonable default device whitelist rules
>         #
>         cat - >> $CONFFILE <<-"EOF"
>         lxc.cgroup.devices.deny = a
>         # /dev/null and zero
>         lxc.cgroup.devices.allow = c 1:3 rwm
>         lxc.cgroup.devices.allow = c 1:5 rwm
>         # consoles
>         lxc.cgroup.devices.allow = c 5:1 rwm
>         lxc.cgroup.devices.allow = c 5:0 rwm
>         lxc.cgroup.devices.allow = c 4:0 rwm
>         lxc.cgroup.devices.allow = c 4:1 rwm
>         # /dev/{,u}random
>         lxc.cgroup.devices.allow = c 1:9 rwm
>         lxc.cgroup.devices.allow = c 1:8 rwm
>         # /dev/pts/* - pts namespaces are "coming soon"
>         lxc.cgroup.devices.allow = c 136:* rwm
>         # rtc 
>         lxc.cgroup.devices.allow = c 254:0 rwm
>         EOF
> 
> The quotes around EOF prevent bash from doing any substitution on the
> file contents.
> 
> Cheers,
> 	-Matt
