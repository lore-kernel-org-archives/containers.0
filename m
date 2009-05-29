From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: [PATCH 0/9] credentials c/r: Introduction
Date: Fri, 29 May 2009 17:32:29 -0500
Message-ID: <20090529223229.GA14536@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-security-module-owner@vger.kernel.org
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: Linux Containers <containers@lists.osdl.org>, Alexey Dobriyan <adobriyan@gmail.com>, Andrew Morgan <morgan@kernel.org>, David Howells <dhowells@redhat.com>, linux-security-module@vger.kernel.org
List-Id: containers.vger.kernel.org

This is the next, hopefully final, version of the patchset to
start supporting credentials in Oren's c/r set.  It addresses
feedback by Alexey, is ported on top of v16, supports c/r of
securebits, and adds support for credentials on ipc objects.

Next I intend to support the LSM ->security field on tasks,
files, and ipc objects.

thanks,
-serge
