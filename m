From: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Example daemon program
Date: Tue, 30 May 2017 17:13:10 +0100
Message-ID: <10295.1496160790@warthog.procyon.org.uk>
References: <149616052408.10194.7774163568767478808.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <149616052408.10194.7774163568767478808.stgit-S6HVgzuS8uM4Awkfq6JHfwNdhmdF6hFW@public.gmane.org>
Content-ID: <10294.1496160790.1-S6HVgzuS8uM4Awkfq6JHfwNdhmdF6hFW@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
Cc: linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, keyrings-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Here's a one-shot example daemon that services user-type keys.

David
---
/* request_key() service daemon
 *
 * Copyright (C) 2017 Red Hat, Inc. All Rights Reserved.
 * Written by David Howells (dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org)
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public Licence
 * as published by the Free Software Foundation; either version
 * 2 of the Licence, or (at your option) any later version.
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <keyutils.h>

#define KEY_SERVICE_NS_UTS		0x0001
#define KEY_SERVICE_NS_IPC		0x0002
#define KEY_SERVICE_NS_MNT		0x0004
#define KEY_SERVICE_NS_PID		0x0008
#define KEY_SERVICE_NS_NET		0x0010
#define KEY_SERVICE_NS_CGROUP		0x0020
#define KEY_SERVICE___ALL_NS		0x003f

#define KEY_SERVICE_FD_CLOEXEC		0x0001
#define KEY_SERVICE_FD_NONBLOCK		0x0002

#define KEYCTL_SERVICE_CREATE		30	/* Create a request_key() service channel */
#define KEYCTL_SERVICE_ADD		31	/* Specify the a request pattern we can service */

int main()
{
	key_serial_t key, tring, pring, sring;
	char buf[128], op[12];
	uid_t uid;
	gid_t gid;
	int kfd, len;

	kfd = keyctl(KEYCTL_SERVICE_CREATE, KEY_SERVICE_FD_CLOEXEC);
	if (kfd == -1) {
		perror("service-create");
		exit(1);
	}

	if (keyctl(KEYCTL_SERVICE_ADD, kfd, "user", 0) == -1) {
		perror("service-add");
		exit(1);
	}

	len = read(kfd, buf, sizeof(buf) - 1);
	if (len == -1) {
		perror("read");
		exit(1);
	}
	buf[len] = 0;

	printf("received %d [%s]\n", len, buf);
	if (sscanf(buf, "%12s %x %x %x %x %x %x",
		   op, &key, &uid, &gid, &tring, &pring, &sring) != 7) {
		fprintf(stderr, "sscanf: Insufficient args decoded\n");
		exit(1);
	}

	if (keyctl_assume_authority(key) == -1) {
		perror("assume");
		exit(1);
	}

	if (keyctl_instantiate(key, "foo_bar", 7, 0) == -1) {
		perror("instantiate");
		exit(1);
	}
	
	exit(0);
}
